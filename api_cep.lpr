program api_cep;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, uHttpServer,SysUtils, uEndereco, uCepService;

var
  Server: THttpServer;

begin

  Server:= THttpServer.Create;

  try
  WriteLn('API CEP - Lazarus');
  WriteLn('Servidor iniciado na porta 8080');
  WriteLn('Pressione ENTER para encerrar.');

  Server.Start;

  ReadLn;

  finally
    Server.Free;
  end;

end.

