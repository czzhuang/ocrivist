unit DjvuUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process;

type
  Tdjvuencoder = (encC44, encCJB2);

function djvumakepage( sourceimage, dest: TFilename; dsedtext: PChar ): Integer;
function djvuaddpage( docname, pagename: TFilename ): Integer;

implementation

function djvumakepage ( sourceimage, dest: TFilename; dsedtext: PChar ): Integer;
var
  Encoder: TProcess;
 //workfolder: String;
  cmd: String;
  encformat: Tdjvuencoder;
begin
  Result := -1;
  Encoder := TProcess.Create(nil);
  Encoder.Options := Encoder.Options + [poWaitOnExit];
  //workfolder := ExtractFileDir(sourceimage);
  if ExtractFileExt(sourceimage)='pbm'
     then encformat := encCJB2
     else encformat := encC44;
  case encformat of
       encC44:  cmd := 'c44 ';
       encCJB2: cmd := 'cjb2 ';
  end;
  Encoder.CommandLine := cmd + sourceimage + #32 + dest;
  Encoder.Execute;
  Result := Encoder.ExitStatus;
  if dsedtext<> nil then
     begin
       Encoder.CommandLine := 'djvused ' + dest + ' -f ' + dsedtext + ' -s';
       Encoder.Execute;
       Result := Encoder.ExitStatus;
     end;
  Encoder.Free;
end;

function djvuaddpage ( docname, pagename: TFilename ) : Integer;
var
  Encoder: TProcess;
  cmd: String;
begin
  Result := -1;
  Encoder := TProcess.Create(nil);
  Encoder.Options := Encoder.Options + [poWaitOnExit];
  if FileExists(docname)
     then cmd := 'djvm -i "' + docname + '" "' + pagename + '"'
     else cmd := 'djvm -c "' + docname + '" "' + pagename + '"';
  Encoder.CommandLine := cmd;
  Encoder.Execute;
  Result := Encoder.ExitStatus;
  Encoder.Free;
end;

end.

