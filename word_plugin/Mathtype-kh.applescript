on LaunchApp(paramString)
	try
		my ActivateApp()
		set pyScript to "import urllib.request, time
req = urllib.request.Request('http://127.0.0.1:45678/new-inline', data=b'', headers={'Content-Type': 'application/json'})
for _ in range(25):
    try:
        with urllib.request.urlopen(req, timeout=1) as resp:
            break
    except Exception:
        time.sleep(0.2)
"
		do shell script "/usr/bin/python3 -c " & quoted form of pyScript & " 2>/dev/null || true"
		return "Success"
	on error
		return "Error: Could not launch app"
	end try
end LaunchApp

on EditEquation(paramString)
	try
		set latexCode to paramString
		if latexCode is missing value or latexCode is "" then
			try
				tell application "Microsoft Word"
					set mySel to selection
					set theShape to missing value
					if (count of inline shapes of mySel) > 0 then
						set theShape to inline shape 1 of mySel
					else
						set selTextObj to text object of mySel
						if (count of inline shapes of selTextObj) > 0 then
							set theShape to inline shape 1 of selTextObj
						end if
					end if
					if theShape is not missing value then
						set latexCode to alternative text of theShape
					end if
				end tell
			end try
		end if
		
		my ActivateApp()
		if latexCode is not missing value and latexCode is not "" then
			set pyScript to "import urllib.request, json, sys, urllib.parse, time
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
if code.startswith(r'\\[' ) and code.endswith(r'\\]'):
    code = code[2:-2].strip()
if code.startswith(r'\\(') and code.endswith(r'\\)'):
    code = code[2:-2].strip()

data = json.dumps({'latex': code}).encode('utf-8')
req = urllib.request.Request('http://127.0.0.1:45678/edit', data=data, headers={'Content-Type': 'application/json'})
for _ in range(25):
    try:
        with urllib.request.urlopen(req, timeout=1) as resp:
            break
    except Exception:
        time.sleep(0.2)
"
			do shell script "/usr/bin/python3 -c " & quoted form of pyScript & " " & quoted form of latexCode & " 2>/dev/null || true"
			return "Success"
		end if
		return "Opened"
	on error errMsg
		return "Error: " & errMsg
	end try
end EditEquation

on ActivateApp()
	try
		do shell script "open -b com.mathtype.kh 2>/dev/null || open -a '/Applications/Mathtype-kh.app' 2>/dev/null || open -a 'Mathtype-kh' 2>/dev/null || true"
	end try
	try
		tell application "Mathtype-kh" to activate
	end try
end ActivateApp

on ToggleApp(paramString)
	try
		set homeDir to POSIX path of (path to home folder)
		set userWorker to homeDir & "Library/Application Scripts/com.microsoft.Word/toggle_tex_worker.py"
		set sysWorker to "/Library/Application Support/Mathtype-kh/toggle_tex_worker.py"
		set pyCmd to "/usr/bin/python3 " & quoted form of userWorker & " 2>/dev/null || /usr/bin/python3 " & quoted form of sysWorker & " 2>/dev/null || python3 " & quoted form of userWorker & " 2>/dev/null || python3 " & quoted form of sysWorker & " 2>/dev/null || true"
		do shell script pyCmd
		return "Success"
	on error errMsg
		return "Error: " & errMsg
	end try
end ToggleApp

on AlignSingleShape(pic)
	tell application "Microsoft Word"
		try
			set altText to alternative text of pic
			if altText contains "ratio:" or altText contains "latex:" or altText contains "$" then
				set rVal to 0.22
				if altText contains "ratio:" then
					set AppleScript's text item delimiters to "ratio:"
					set p1 to text item 2 of altText
					set AppleScript's text item delimiters to "|"
					set rStr to text item 1 of p1
					set AppleScript's text item delimiters to ""
					try
						set rVal to (rStr as real)
					on error
						set rVal to 0.22
					end try
				end if
				
				-- Smart upgrade for equations created when ratio defaulted to 0.22 or missing
				if rVal <= 0.23 then
					if altText contains "cases" or altText contains "matrix" or altText contains "aligned" or altText contains "\\\\" then
						set rVal to 0.4185
					else if altText contains "int" then
						set rVal to 0.39
					else if altText contains "frac" then
						set rVal to 0.3
					else if rVal <= 0.0 then
						set rVal to 0.22
					end if
				end if
				
				set h to height of pic
				set actualDepth to h * rVal
				set font position of font object of (text object of pic) to -actualDepth
				return true
			end if
		on error
			return false
		end try
		return false
	end tell
end AlignSingleShape

on AlignSelection(paramString)
	try
		tell application "Microsoft Word"
			set selObj to selection
			set sPos to start of content of (text object of selObj)
			set ePos to end of content of (text object of selObj)
			if sPos is equal to ePos then
				set sPos to sPos - 2
				set ePos to ePos + 2
			end if
			
			set allShapes to inline shapes of active document
			set alignedCount to 0
			repeat with i from 1 to (count of allShapes)
				set pic to item i of allShapes
				try
					set picPos to start of content of (text object of pic)
					if picPos >= sPos and picPos <= ePos then
						if my AlignSingleShape(pic) then
							set alignedCount to alignedCount + 1
						end if
					end if
				end try
			end repeat
			return "Aligned " & alignedCount & " equation(s) in selection"
		end tell
	on error errMsg
		return "Error: " & errMsg
	end try
end AlignSelection

on AlignDocument(paramString)
	try
		tell application "Microsoft Word"
			set allShapes to inline shapes of active document
			set alignedCount to 0
			repeat with i from 1 to (count of allShapes)
				set pic to item i of allShapes
				if my AlignSingleShape(pic) then
					set alignedCount to alignedCount + 1
				end if
			end repeat
			return "Aligned " & alignedCount & " equation(s) in document"
		end tell
	on error errMsg
		return "Error: " & errMsg
	end try
end AlignDocument
