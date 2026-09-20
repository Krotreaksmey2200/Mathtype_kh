#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Toggle TeX Worker for Mathtype-kh Word Plugin
Converts every $...$ or $$...$$ in Microsoft Word selection into a Mathtype-kh
equation image in-place, or converts selected equation images back to TeX text.
Runs completely in the background without opening or focusing Mathtype-kh.
"""

import os
import sys
import subprocess
import tempfile
import shutil
import re
import time

def run_apple_script(scpt):
    try:
        p = subprocess.run(["/usr/bin/osascript", "-e", scpt], capture_output=True, text=True)
        return p.stdout.strip(), p.stderr.strip()
    except Exception as e:
        return "", str(e)

def find_tex_bin():
    candidates = [
        "/Library/TeX/texbin",
        "/usr/local/texlive/2026/bin/universal-darwin",
        "/usr/local/texlive/2025/bin/universal-darwin",
        "/usr/local/bin",
        "/opt/homebrew/bin"
    ]
    for c in candidates:
        if os.path.exists(os.path.join(c, "latex")):
            return c
    return "/Library/TeX/texbin"

def get_configured_engine():
    engine_file = os.path.expanduser("~/Library/Application Support/Mathtype-kh/engine.txt")
    if os.path.exists(engine_file):
        try:
            with open(engine_file, "r", encoding="utf-8") as f:
                eng = f.read().strip().lower()
                if eng in ("xelatex", "pdflatex", "auto"):
                    return eng
        except Exception:
            pass
    return "auto"

def compile_latex(formula, font_size=12.0):
    temp_dir = tempfile.mkdtemp(prefix="mtk_toggle_")
    try:
        tex_path = os.path.join(temp_dir, "eq.tex")
        dvi_path = os.path.join(temp_dir, "eq.dvi")
        png_path = os.path.join(temp_dir, "eq.png")
        svg_path = os.path.join(temp_dir, "eq.svg")
        
        trimmed = formula.strip()
        if trimmed.startswith("$$") and trimmed.endswith("$$"):
            trimmed = trimmed[2:-2].strip()
        elif trimmed.startswith("$") and trimmed.endswith("$"):
            trimmed = trimmed[1:-1].strip()
        elif trimmed.startswith(r"\[") and trimmed.endswith(r"\]"):
            trimmed = trimmed[2:-2].strip()
            
        if trimmed.startswith(r"\begin{align") or trimmed.startswith(r"\begin{equation"):
            body = trimmed
        else:
            body = f"$ \\displaystyle {trimmed} $"
            
        has_unicode = any(ord(c) > 127 for c in formula)
        configured_engine = get_configured_engine()
        if configured_engine == "xelatex":
            use_xelatex = True
        elif configured_engine == "pdflatex":
            use_xelatex = False
        else:
            use_xelatex = has_unicode

        tex_bin = find_tex_bin()
        env = os.environ.copy()
        env["PATH"] = f"{tex_bin}:/usr/bin:/bin:/usr/sbin:/sbin"

        if use_xelatex:
            user_preamble = r"""\usepackage{amsmath,amssymb,amsfonts}
\usepackage[version=4]{mhchem}"""
            preamble_path = os.path.expanduser("~/Library/Application Support/Mathtype-kh/preamble.tex")
            if os.path.exists(preamble_path):
                try:
                    with open(preamble_path, "r", encoding="utf-8") as pf:
                        content = pf.read().strip()
                        if content:
                            user_preamble = content
                except Exception:
                    pass

            if "fontspec" in user_preamble or r"\setmainfont" in user_preamble:
                xe_preamble = user_preamble
            else:
                xe_preamble = rf"""{user_preamble}
\usepackage{xcolor}
\nopagecolor
\usepackage{fontspec}
\IfFontExistsTF{{Khmer OS Battambang}}{{
    \setmainfont{{Khmer OS Battambang}}
}}{{
    \IfFontExistsTF{{Khmer OS}}{{
        \setmainfont{{Khmer OS}}
    }}{{
        \IfFontExistsTF{{Noto Sans Khmer}}{{
            \setmainfont{{Noto Sans Khmer}}
        }}{{
            \IfFontExistsTF{{Khmer Sangam MN}}{{
                \setmainfont{{Khmer Sangam MN}}
            }}{{
                \setmainfont{{Khmer MN}}
            }}
        }}
    }}
}}
"""
            is_display = trimmed.startswith(r"\begin{align") or trimmed.startswith(r"\begin{equation") or trimmed.startswith(r"\[")
            if is_display:
                measure_code = f"\\setbox0=\\vbox{{{body}}}%\n\\typeout{{MATHTYPE_DEPTH:\\the\\dp0;TOTAL_HEIGHT:\\the\\dimexpr\\ht0+\\dp0\\relax}}%\n\\unvbox0"
            else:
                measure_code = f"\\setbox0=\\hbox{{{body}}}%\n\\typeout{{MATHTYPE_DEPTH:\\the\\dp0;TOTAL_HEIGHT:\\the\\dimexpr\\ht0+\\dp0\\relax}}%\n\\unhbox0"

            tex_code = rf"""\documentclass[preview,border=0pt]{{standalone}}
{xe_preamble}
\begin{{document}}
\fontsize{{{font_size}pt}}{{{font_size * 1.25}pt}}\selectfont
{measure_code}
\end{{document}}
"""
            with open(tex_path, "w", encoding="utf-8") as f:
                f.write(tex_code)

            xdv_path = os.path.join(temp_dir, "eq.xdv")
            pdf_path = os.path.join(temp_dir, "eq.pdf")

            # 1. Run xelatex -no-pdf
            subprocess.run([os.path.join(tex_bin, "xelatex"), "-no-pdf", "-interaction=nonstopmode", "eq.tex"],
                           cwd=temp_dir, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if not os.path.exists(xdv_path):
                return None

            # 2. Run xdvipdfmx
            subprocess.run([os.path.join(tex_bin, "xdvipdfmx"), "-o", "eq.pdf", "eq.xdv"],
                           cwd=temp_dir, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            # 3. Run dvisvgm to get exact depth
            subprocess.run([os.path.join(tex_bin, "dvisvgm"), "--no-styles", "--exact-bbox", "eq.xdv", "-o", "eq.svg"],
                           cwd=temp_dir, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

            # 4. Render PDF to 300 DPI Transparent PNG
            app_bin = "/Applications/Mathtype-kh.app/Contents/MacOS/Mathtype-kh"
            if os.path.exists(app_bin):
                subprocess.run([app_bin, "--render-pdf", pdf_path, png_path, "300"],
                                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            elif os.path.exists("/opt/homebrew/bin/pdftoppm"):
                out_base = os.path.join(temp_dir, "eq_ppm")
                subprocess.run(["/opt/homebrew/bin/pdftoppm", "-png", "-r", "300", pdf_path, out_base],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                ppm_file = f"{out_base}-1.png"
                if os.path.exists(ppm_file):
                    shutil.move(ppm_file, png_path)

            if not os.path.exists(png_path):
                return None
        else:
            preamble_path = os.path.expanduser("~/Library/Application Support/Mathtype-kh/preamble.tex")
            preamble = "\\usepackage{lmodern}\n\\usepackage{amsmath,amssymb,amsfonts}\n\\usepackage{xcolor}\n\\nopagecolor"
            if os.path.exists(preamble_path):
                try:
                    with open(preamble_path, "r", encoding="utf-8") as pf:
                        content = pf.read().strip()
                        if content:
                            preamble = content
                except Exception:
                    pass

            # Filter out fontspec and XeTeX font commands so pdflatex never fails
            if "fontspec" in preamble or "\\setmainfont" in preamble or "\\IfFontExistsTF" in preamble:
                clean_lines = []
                for line in preamble.splitlines():
                    tl = line.strip()
                    if "fontspec" in tl or "\\setmainfont" in tl or "\\IfFontExistsTF" in tl or "Khmer" in tl:
                        continue
                    if tl in ("{", "}", "}{", "}}{", "}}"):
                        continue
                    clean_lines.append(line)
                preamble = "\n".join(clean_lines)

            is_display = trimmed.startswith(r"\begin{align") or trimmed.startswith(r"\begin{equation") or trimmed.startswith(r"\[")
            if is_display:
                measure_code = f"\\setbox0=\\vbox{{{body}}}%\n\\typeout{{MATHTYPE_DEPTH:\\the\\dp0;TOTAL_HEIGHT:\\the\\dimexpr\\ht0+\\dp0\\relax}}%\n\\unvbox0"
            else:
                measure_code = f"\\setbox0=\\hbox{{{body}}}%\n\\typeout{{MATHTYPE_DEPTH:\\the\\dp0;TOTAL_HEIGHT:\\the\\dimexpr\\ht0+\\dp0\\relax}}%\n\\unhbox0"

            tex_code = rf"""\documentclass[preview,border=0pt]{{standalone}}
{preamble}
\begin{{document}}
\fontsize{{{font_size}pt}}{{{font_size * 1.25}pt}}\selectfont
{measure_code}
\end{{document}}
"""
            with open(tex_path, "w", encoding="utf-8") as f:
                f.write(tex_code)

            # 1. Run latex
            subprocess.run([os.path.join(tex_bin, "latex"), "-interaction=nonstopmode", "eq.tex"],
                           cwd=temp_dir, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if not os.path.exists(dvi_path):
                return None

            # 2. Run dvipng (300 DPI Transparent)
            subprocess.run([os.path.join(tex_bin, "dvipng"), "-D", "300", "-T", "tight", "-bg", "Transparent", "-o", "eq.png", "eq.dvi"],
                           cwd=temp_dir, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if not os.path.exists(png_path):
                return None

            # 3. Run dvisvgm to get exact depth
            subprocess.run([os.path.join(tex_bin, "dvisvgm"), "--no-styles", "--no-fonts", "--exact-bbox", "eq.dvi", "-o", "eq.svg"],
                           cwd=temp_dir, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        # Parse exact depth from TeX log if available
        log_path = os.path.join(temp_dir, "eq.log")
        if os.path.exists(log_path):
            with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
                log_content = f.read()
            m_log = re.search(r"MATHTYPE_DEPTH:([-\d.]+)pt;TOTAL_HEIGHT:([-\d.]+)pt", log_content)
            if m_log:
                p_depth = float(m_log.group(1))
                p_tot = float(m_log.group(2))
                if p_tot > 0 and p_depth >= 0:
                    depth = p_depth
                    ratio = p_depth / p_tot

        if os.path.exists(svg_path):
            with open(svg_path, "r", encoding="utf-8", errors="ignore") as f:
                svg = f.read()
            m = re.search(r"viewBox\s*=\s*['\"]\s*([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)", svg)
            if m:
                min_y = float(m.group(2))
                width = float(m.group(3))
                height = float(m.group(4))
                if ratio <= 0.0 or ratio > 0.85:
                    eff_min_y = (min_y + 72.0) if use_xelatex else min_y
                    depth = eff_min_y + height
                    if height > 0:
                        cand_ratio = depth / height
                        if 0.0 <= cand_ratio <= 0.85:
                            ratio = cand_ratio

        # Smart fallback if needed
        if ratio <= 0.0 or ratio > 0.85:
            if any(k in formula for k in ["cases", "matrix", "aligned", r"\\"]):
                ratio = 0.4185
            elif "int" in formula:
                ratio = 0.39
            elif "frac" in formula:
                ratio = 0.30
            else:
                ratio = 0.22
            depth = height * ratio
                    
        # 4. Copy PNG to Word Sandbox tmp folder
        home = os.path.expanduser("~")
        word_tmp = os.path.join(home, "Library/Containers/com.microsoft.Word/Data/tmp")
        os.makedirs(word_tmp, exist_ok=True)
        dest_filename = f"mathtype_eq_{int(time.time() * 1000)}_{os.getpid()}_{hash(formula) & 0xffff}.png"
        dest_path = os.path.join(word_tmp, dest_filename)
        shutil.copyfile(png_path, dest_path)
        
        return {
            "png_path": dest_path,
            "width": width,
            "height": height,
            "depth": depth,
            "ratio": ratio,
            "latex": trimmed
        }
    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)

def main():
    # 1. First check if selection currently has an equation inline picture -> convert to $...$
    check_pic_scpt = """
    tell application "Microsoft Word"
        if (count of documents) is 0 then return "NO_DOC"
        set s to selection
        set st to text object of s
        set c to count of inline shapes of st
        if c > 0 then
            set conv to 0
            repeat with i from c to 1 by -1
                set p to inline shape i of st
                set alt to alternative text of p
                if alt contains "latex:" then
                    set AppleScript's text item delimiters to "latex:"
                    set lCode to text item 2 of alt
                    set AppleScript's text item delimiters to ""
                    set content of text object of p to "$" & lCode & "$"
                    set conv to conv + 1
                end if
            end repeat
            return "PIC:" & (conv as text)
        end if
        return "NO_PIC"
    end tell
    """
    out, _ = run_apple_script(check_pic_scpt)
    if out.startswith("PIC:"):
        sys.exit(0)

    # 2. Get selection text and start offset
    get_sel_scpt = """
    tell application "Microsoft Word"
        if (count of documents) is 0 then return "NO_DOC"
        set sel to selection
        set selStart to start of content of text object of sel
        set selText to content of text object of sel
        return (selStart as text) & "|||" & selText
    end tell
    """
    out, _ = run_apple_script(get_sel_scpt)
    if "|||" not in out:
        sys.exit(0)
        
    start_str, sel_text = out.split("|||", 1)
    sel_start = int(start_str)
    
    # 3. Find all formulas $...$ and $$...$$
    pattern = re.compile(r"\$\$(.+?)\$\$|\$((?:\\\$|[^\$])+)\$|\\\[(.+?)\\\]", re.DOTALL)
    matches = []
    for m in pattern.finditer(sel_text):
        matches.append((m.start(), m.end(), m.group(0)))
        
    # If no formulas found in selected text and selection is collapsed (or single char), check current paragraph
    if not matches and len(sel_text.strip()) <= 1:
        get_para_scpt = """
        tell application "Microsoft Word"
            try
                set sel to selection
                set p to paragraph 1 of (text object of sel)
                set pStart to start of content of (text object of p)
                set pText to content of text object of p
                return (pStart as text) & "|||" & pText
            on error
                return "ERR"
            end try
        end tell
        """
        p_out, _ = run_apple_script(get_para_scpt)
        if "|||" in p_out:
            p_start_str, p_text = p_out.split("|||", 1)
            p_start = int(p_start_str)
            p_matches = []
            for m in pattern.finditer(p_text):
                m_start = p_start + m.start()
                m_end = p_start + m.end()
                if (m_start - 2) <= sel_start <= (m_end + 2):
                    p_matches.append((m.start(), m.end(), m.group(0)))
            if not p_matches:
                all_p = list(pattern.finditer(p_text))
                if len(all_p) == 1:
                    m = all_p[0]
                    p_matches.append((m.start(), m.end(), m.group(0)))
            if p_matches:
                sel_start = p_start
                sel_text = p_text
                matches = p_matches

    # If still no formulas found in text, check if any equation shapes are inside or adjacent to selection
    if not matches:
        check_doc_pics = f"""
        tell application "Microsoft Word"
            set sStart to {max(0, sel_start - 2)}
            set sEnd to {sel_start + len(sel_text) + 2}
            set c to count of inline shapes of active document
            set conv to 0
            repeat with i from c to 1 by -1
                set p to inline shape i of active document
                set pStart to start of content of text object of p
                if pStart >= sStart and pStart <= sEnd then
                    set alt to alternative text of p
                    if alt contains "latex:" then
                        set AppleScript's text item delimiters to "latex:"
                        set lCode to text item 2 of alt
                        set AppleScript's text item delimiters to ""
                        set content of text object of p to "$" & lCode & "$"
                        set conv to conv + 1
                    end if
                end if
            end repeat
            return conv
        end tell
        """
        run_apple_script(check_doc_pics)
        sys.exit(0)

    # 4. Replace each formula from end of selection to start
    for s_off, e_off, formula in reversed(matches):
        res = compile_latex(formula)
        if not res:
            continue
            
        doc_s = sel_start + s_off
        doc_e = sel_start + e_off
        png_p = res["png_path"]
        w = res["width"]
        h = res["height"]
        dep = res["depth"]
        rat = res["ratio"]
        lat = res["latex"].replace("\\", "\\\\").replace("\"", "\\\"")
        
        replace_scpt = f"""
        tell application "Microsoft Word"
            set r to create range active document start {doc_s} end {doc_e}
            select r
            set content of text object of selection to ""
            make new inline picture at (text object of selection) with properties {{file name:"{png_p}"}}
            set c to count of inline shapes of active document
            repeat with i from 1 to c
                set ishp to inline shape i of active document
                if (start of content of text object of ishp) = {doc_s} then
                    set width of ishp to {w:.2f}
                    set height of ishp to {h:.2f}
                    set font position of font object of (text object of ishp) to -{dep:.2f}
                    set alternative text of ishp to "ratio:{rat:.4f}|latex:{lat}"
                    exit repeat
                end if
            end repeat
        end tell
        """
        run_apple_script(replace_scpt)

if __name__ == "__main__":
    main()
