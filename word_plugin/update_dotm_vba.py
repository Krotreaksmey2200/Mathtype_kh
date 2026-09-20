import pyopenvba.word as pw
import shutil
import os

vba_code = '''Attribute VB_Name = "Module1"
' ==============================================================================
' Microsoft Word Add-in: Mathtype-kh Plugin Suite (Khmer Edition)
' ==============================================================================
Option Explicit

Public gWordAppEvents As clsWordEvents

Public Sub AutoExec()
    On Error Resume Next
    InitWordAppEvents
End Sub

Public Sub AutoOpen()
    On Error Resume Next
    InitWordAppEvents
End Sub

Public Sub InitWordAppEvents()
    On Error Resume Next
    If gWordAppEvents Is Nothing Then
        Set gWordAppEvents = New clsWordEvents
        Set gWordAppEvents.App = Word.Application
    End If
    ThisDocument.InitDocAppEvents
End Sub

' ------------------------------------------------------------------------------
' RIBBON CALLBACK HANDLERS
' ------------------------------------------------------------------------------

' Button 1: Open Mathtype-kh
Public Sub OpenMacTeXMathEditor(control As IRibbonControl)
    On Error GoTo ErrorHandler
    Dim result As String
    #If Mac Then
        result = AppleScriptTask("MacTeXMathEditor.scpt", "LaunchApp", "")
        If Err.Number <> 0 Or result = "" Or InStr(result, "Error") > 0 Then
            Err.Clear
            Dim scpt As String
            scpt = "do shell script ""open -b com.mathtype.kh 2>/dev/null || open -a '/Applications/Mathtype-kh.app' 2>/dev/null || open -a 'Mathtype-kh' 2>/dev/null || true; python3 -c \""import urllib.request, time; req = urllib.request.Request('http://127.0.0.1:45678/new-inline', data=b'', headers={'Content-Type': 'application/json'}); [urllib.request.urlopen(req) for _ in range(15)]\"" 2>/dev/null &"""
            MacScript scpt
        End If
    #End If
    Exit Sub
ErrorHandler:
    MsgBox "Cannot open Mathtype-kh: " & Err.Description, vbExclamation, "Mathtype-kh"
End Sub

' Button 2: Edit Selected Equation
Public Sub EditSelectedEquation(Optional ByVal altText As String = "")
    On Error GoTo ErrorHandler
    
    If altText = "" Then
        On Error Resume Next
        If Selection.InlineShapes.Count > 0 Then
            altText = Selection.InlineShapes(1).AlternativeText
        End If
        If altText = "" And Selection.ShapeRange.Count > 0 Then
            altText = Selection.ShapeRange(1).AlternativeText
        End If
        If altText = "" And Selection.Range.InlineShapes.Count > 0 Then
            altText = Selection.Range.InlineShapes(1).AlternativeText
        End If
        If altText = "" And Selection.Range.ShapeRange.Count > 0 Then
            altText = Selection.Range.ShapeRange(1).AlternativeText
        End If
        If altText = "" Then
            Dim ishp As InlineShape
            Dim sStart As Long, sEnd As Long
            sStart = Selection.Start: sEnd = Selection.End
            For Each ishp In ActiveDocument.InlineShapes
                If (ishp.Range.Start <= sEnd + 2) And (ishp.Range.End >= sStart - 2) Then
                    altText = ishp.AlternativeText
                    Exit For
                End If
            Next ishp
        End If
    End If
    
    If altText = "" Then
        OpenMacTeXMathEditor Nothing
        Exit Sub
    End If
    
    #If Mac Then
        Dim result As String
        result = AppleScriptTask("MacTeXMathEditor.scpt", "EditEquation", altText)
        If Err.Number <> 0 Or result = "" Or InStr(result, "Error") > 0 Then
            Err.Clear
            Dim cleanAlt As String
            cleanAlt = Replace(altText, "'", "'\''")
            cleanAlt = Replace(cleanAlt, """", "\""")
            Dim scpt As String
            scpt = "do shell script ""open -b com.mathtype.kh 2>/dev/null || open -a '/Applications/Mathtype-kh.app' 2>/dev/null || open -a 'Mathtype-kh' 2>/dev/null || true; python3 -c \""import urllib.request, json, sys, urllib.parse; raw = '''" & cleanAlt & "'''; parts = raw.split('|latex:'); code = parts[1] if len(parts) > 1 else (raw.split('|')[1] if '|' in raw else raw); code = urllib.parse.unquote(code) if '%' in code else code; req = urllib.request.Request('http://127.0.0.1:45678/edit', data=json.dumps({'latex': code}).encode('utf-8'), headers={'Content-Type': 'application/json'}); urllib.request.urlopen(req)\"""" 2>/dev/null &"""
            MacScript scpt
        End If
    #End If
    Exit Sub
ErrorHandler:
    MsgBox "Cannot edit equation: " & Err.Description, vbExclamation, "Mathtype-kh"
End Sub

Public Sub OnEditEquationRibbonClick(control As IRibbonControl)
    EditSelectedEquation ""
End Sub

Public Sub OnOpenMathEditorClick(Optional control As Object)
    OpenMacTeXMathEditor Nothing
End Sub

Public Sub LaunchApp(Optional dummy As String)
    OpenMacTeXMathEditor Nothing
End Sub

' Button 3: Toggle TeX
Public Sub ToggleTeX(control As IRibbonControl)
    On Error GoTo ErrorHandler
    Dim result As String
    #If Mac Then
        result = AppleScriptTask("MacTeXMathEditor.scpt", "ToggleApp", "")
        If Err.Number <> 0 Or result = "" Or InStr(result, "Error") > 0 Then
            Err.Clear
            Dim scpt As String
            scpt = "do shell script ""python3 ~/Library/Application\\ Scripts/com.microsoft.Word/toggle_tex_worker.py 2>/dev/null || /usr/bin/python3 ~/Library/Application\\ Scripts/com.microsoft.Word/toggle_tex_worker.py 2>/dev/null || true"""
            MacScript scpt
        End If
    #End If
    Exit Sub
ErrorHandler:
    MsgBox "Cannot toggle TeX: " & Err.Description, vbExclamation, "Mathtype-kh"
End Sub

Public Sub OnToggleTeXClick(Optional control As Object)
    ToggleTeX Nothing
End Sub

' Button 4: Align Selection
Public Sub OnAlignSelectionClick(control As IRibbonControl)
    AlignSelection
End Sub

' Button 5: Align Document
Public Sub OnAlignDocumentClick(control As IRibbonControl)
    AlignDocument
End Sub

' ------------------------------------------------------------------------------
' BASELINE ALIGNMENT FUNCTIONS
' ------------------------------------------------------------------------------

Public Sub AlignSelection()
    On Error Resume Next
    Dim ishp As InlineShape
    Dim count As Long
    count = 0
    
    If Selection.InlineShapes.Count > 0 Then
        For Each ishp In Selection.InlineShapes
            If AlignSingleShape(ishp) Then count = count + 1
        Next ishp
    ElseIf Selection.Range.InlineShapes.Count > 0 Then
        For Each ishp In Selection.Range.InlineShapes
            If AlignSingleShape(ishp) Then count = count + 1
        Next ishp
    Else
        Dim sStart As Long, sEnd As Long
        sStart = Selection.Start
        sEnd = Selection.End
        If sStart = sEnd Then
            sStart = sStart - 2
            sEnd = sEnd + 2
        End If
        For Each ishp In ActiveDocument.InlineShapes
            If (ishp.Range.Start <= sEnd) And (ishp.Range.End >= sStart) Then
                If AlignSingleShape(ishp) Then count = count + 1
            End If
        Next ishp
    End If
    
    If count > 0 Then
        MsgBox "Aligned " & count & " equation(s) in selection!", vbInformation, "Mathtype-kh"
    Else
        MsgBox "No equation found in selection!", vbExclamation, "Mathtype-kh"
    End If
End Sub

Public Sub AlignDocument()
    On Error Resume Next
    Dim ishp As InlineShape
    Dim count As Long
    count = 0
    
    For Each ishp In ActiveDocument.InlineShapes
        If AlignSingleShape(ishp) Then count = count + 1
    Next ishp
    
    If count > 0 Then
        MsgBox "Aligned " & count & " equation(s) in document!", vbInformation, "Mathtype-kh"
    Else
        MsgBox "No equation found in document!", vbInformation, "Mathtype-kh"
    End If
End Sub

Private Function AlignSingleShape(ishp As InlineShape) As Boolean
    On Error Resume Next
    AlignSingleShape = False
    If ishp Is Nothing Then Exit Function
    
    Dim altText As String
    altText = ishp.AlternativeText
    If InStr(altText, "ratio:") = 0 And InStr(altText, "latex:") = 0 And InStr(altText, "$") = 0 Then Exit Function
    
    Dim ratioVal As Double
    ratioVal = ExtractRatio(altText)
    
    ' Smart upgrade for legacy/default 0.22 ratio or missing ratio
    If ratioVal <= 0.23 Then
        If InStr(altText, "cases") > 0 Or InStr(altText, "matrix") > 0 Or InStr(altText, "aligned") > 0 Or InStr(altText, "\\") > 0 Then
            ratioVal = 0.4185
        ElseIf InStr(altText, "int") > 0 Then
            ratioVal = 0.39
        ElseIf InStr(altText, "frac") > 0 Then
            ratioVal = 0.3
        ElseIf ratioVal <= 0# Then
            ratioVal = 0.22
        End If
    End If
    
    If ratioVal > 0# Then
        Dim shapeHeight As Single
        shapeHeight = ishp.Height
        Dim shift As Single
        shift = shapeHeight * ratioVal
        ishp.Range.Font.Position = -shift
        AlignSingleShape = True
    End If
End Function

Private Function ExtractRatio(altText As String) As Double
    On Error Resume Next
    ExtractRatio = 0#
    Dim pos1 As Long, pos2 As Long
    pos1 = InStr(altText, "ratio:")
    If pos1 > 0 Then
        pos1 = pos1 + 6
        pos2 = InStr(pos1, altText, "|")
        If pos2 = 0 Then pos2 = InStr(pos1, altText, " ")
        If pos2 = 0 Then pos2 = Len(altText) + 1
        Dim rStr As String
        rStr = Mid(altText, pos1, pos2 - pos1)
        rStr = Replace(rStr, ",", ".")
        ExtractRatio = Val(rStr)
    End If
End Function
'''

target_paths = [
    "word_plugin/Mathtype-kh.dotm",
    "word_plugin/pkg_build/root/Library/Application Support/Mathtype-kh/Mathtype-kh.dotm",
    os.path.expanduser("~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Startup.localized/Word/Mathtype_kh.dotm"),
    os.path.expanduser("~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Startup.localized/Word/Mathtype-kh.dotm")
]

for p in target_paths:
    if os.path.exists(p):
        print(f"Updating {p}...")
        try:
            doc = pw.WordFile(p)
            doc.set_module("Module1", vba_code)
            doc.save()
            print(f"Successfully updated {p}")
        except Exception as e:
            print(f"Error updating {p}: {e}")
