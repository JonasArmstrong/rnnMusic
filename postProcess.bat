@ECHO OFF
SET charFile=G:\midiDatabase\char-rnn
SET outDir=G:\midiDatabase\sampleOut
SET saveDir=G:\midiDatabase\output\reelSample\save

SET InFile=Data.txt
SET OutFile=Output.txt
IF EXIST "%OutFile%" DEL "%OutFile%"
SET TempFile=Temp.txt
IF EXIST "%TempFile%" DEL "%TempFile%"

REM taking sample and saving to file sample.txt
cd \D %charFile%
python sample.py --save_dir %saveDir% -n %%1 > %outDir%/%InFile%
cd %outDir%
ECHO Sample has been taken, extracting relevant text
PAUSE


FOR /F "tokens=*" %%A IN ('FINDSTR /N "X:\<xyz" "%InFile%"') DO (
   CALL :RemovePrecedingWordA "%%A"
   FOR /F "tokens=1 delims=:" %%B IN ('ECHO.%%A') DO (
      MORE +%%B "%InFile%"> "%TempFile%"
      FINDSTR /V "wordB" "%TempFile%">> "%OutFile%"
      FOR /F "tokens=*" %%C IN ('FINDSTR "\r\n\r\n" "%InFile%"') DO (
         CALL :RemoveWordB "%%C"
         IF EXIST "%TempFile%" DEL "%TempFile%"
         GOTO :eof
         )
      )
   )
GOTO :eof

:RemovePrecedingWordA
SET String=%~1
SET String=%String:*wordA =%
ECHO.%String%> "%OutFile%"
GOTO :eof

:RemoveWordB
REM Replace "wordB" with a character that we don't expect in text that we will then use as a delimiter (` in this case)
SET LastLine=%~1
SET LastLine=%LastLine:wordB=`%
FOR /F "tokens=1 delims=`" %%A IN ('ECHO.%LastLine%') DO ECHO.%%A>> "%OutFile%"
GOTO :eof

REM http://stackoverflow.com/questions/15042909/extract-part-of-a-text-file-using-batch-dos
