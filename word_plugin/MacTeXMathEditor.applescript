on LaunchApp(paramString)
	try
		my ActivateApp()
		do shell script "curl -s -m 2 -X POST http://127.0.0.1:45678/new-inline || true"
		return "Success"
	on error
		return "Error: Could not launch app"
	end try
end LaunchApp

on EditEquation(paramString)
	try
		set latexCode to paramString
		if latexCode is "" or latexCode is missing value then
			tell application "Microsoft Word"
				set mySel to selection
				set selTextObj to text object of mySel
				if (count of inline shapes of selTextObj) > 0 then
					set theShape to inline shape 1 of selTextObj
					set latexCode to alternative text of theShape
				end if
			end tell
		end if
		
		if latexCode is not missing value and latexCode is not "" then
			my ActivateApp()
			set pyScript to "import urllib.request, json, sys, urllib.parse
raw = sys.argv[1]
if '|latex:' in raw:
    code = raw.split('|latex:')[1]
elif '|' in raw:
    code = raw.split('|')[1]
else:
    code = raw
if code.startswith('ratio:'):
    code = code.split(':', 1)[1]
if '%' in code:
    code = urllib.parse.unquote(code)
code = code.strip()
if code.startswith('$') and code.endswith('$'):
    code = code[1:-1].strip()
if code.startswith('$$') and code.endswith('$$'):
    code = code[2:-2].strip()
if code.startswith(r'\\[') and code.endswith(r'\\]'):
    code = code[2:-2].strip()

data = json.dumps({'latex': code}).encode('utf-8')
req = urllib.request.Request('http://127.0.0.1:45678/edit', data=data, headers={'Content-Type': 'application/json'})
try:
    urllib.request.urlopen(req, timeout=2)
except Exception:
    pass
"
			do shell script "python3 -c " & quoted form of pyScript & " " & quoted form of latexCode
			return "Success"
		end if
		return "NoEquation"
	on error errMsg
		return "Error: " & errMsg
	end try
end EditEquation

on ActivateApp()
	try
		tell application "Mathtype-kh" to activate
	on error
		try
			tell application "MathType 7" to activate
		on error
			try
				do shell script "open -a '/Applications/Mathtype-kh.app' 2>/dev/null || open -a '/Applications/MathType 7.app' 2>/dev/null || open -a '/Applications/MathType.app' 2>/dev/null || true"
			end try
		end try
	end try
end ActivateApp

on ToggleApp(paramString)
	try
		set homeDir to POSIX path of (path to home folder)
		set userWorker to homeDir & "Library/Application Scripts/com.microsoft.Word/toggle_tex_worker.py"
		set sysWorker to "/Library/Application Support/Mathtype-kh/toggle_tex_worker.py"
		set sysWorkerOld to "/Library/Application Support/Mathtype_kh/toggle_tex_worker.py"
		set pyCmd to "python3 " & quoted form of userWorker & " 2>/dev/null || python3 " & quoted form of sysWorker & " 2>/dev/null || python3 " & quoted form of sysWorkerOld & " 2>/dev/null || true"
		do shell script pyCmd
		return "Success"
	on error errMsg
		return "Error: " & errMsg
	end try
end ToggleApp

on AlignSelection()
	try
		tell application "Microsoft Word"
			set selObj to selection
			set selText to text object of selObj
			set pCount to count of inline shapes of selText
			set alignedCount to 0
			repeat with i from 1 to pCount
				set pic to inline shape i of selText
				set altText to alternative text of pic
				if altText contains "ratio:" then
					set AppleScript's text item delimiters to "ratio:"
					set p1 to text item 2 of altText
					set AppleScript's text item delimiters to "|"
					set rStr to text item 1 of p1
					set AppleScript's text item delimiters to ""
					set rVal to (run script rStr)
					set h to height of pic
					set actualDepth to h * rVal
					set font position of font object of (text object of pic) to -actualDepth
					set alignedCount to alignedCount + 1
				end if
			end repeat
			return "Aligned " & alignedCount & " equation(s)"
		end tell
	on error errMsg
		return "Error: " & errMsg
	end try
end AlignSelection

on AlignDocument()
	try
		tell application "Microsoft Word"
			set activeDoc to active document
			set pCount to count of inline shapes of activeDoc
			set alignedCount to 0
			repeat with i from 1 to pCount
				set pic to inline shape i of activeDoc
				set altText to alternative text of pic
				if altText contains "ratio:" then
					set AppleScript's text item delimiters to "ratio:"
					set p1 to text item 2 of altText
					set AppleScript's text item delimiters to "|"
					set rStr to text item 1 of p1
					set AppleScript's text item delimiters to ""
					set rVal to (run script rStr)
					set h to height of pic
					set actualDepth to h * rVal
					set font position of font object of (text object of pic) to -actualDepth
					set alignedCount to alignedCount + 1
				end if
			end repeat
			return "Aligned " & alignedCount & " equation(s)"
		end tell
	on error errMsg
		return "Error: " & errMsg
	end try
end AlignDocument
