
unit uApiController;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fphttpserver;

type
  TApiController = class
  public
    procedure HandleRequest(
      var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);
  end;

implementation

procedure TApiController.HandleRequest(
  var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse);
begin
  AResponse.ContentType := 'application/json; charset=utf-8';

  if (ARequest.Method = 'GET') and
     (ARequest.PathInfo = '/health') then
  begin
    AResponse.Code := 200;
    AResponse.Content :=
      '{"status":"online","message":"API CEP funcionando!"}';
  end
  else
  begin
    AResponse.Code := 404;
    AResponse.Content :=
      '{"error":"Rota nao encontrada"}';
  end;
end;

end.

