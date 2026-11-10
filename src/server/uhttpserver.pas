
unit uHttpServer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fphttpserver, uApiController;

type
  THttpServer = class
  private

    //TFPHTTPServer: é uma classe de servidor HTTP do Free Pascal.
    FServer: TFPHTTPServer;
    FController: TApiController;

    procedure HandleRequest(Sender: TObject;
      var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
  end;

implementation

constructor THttpServer.Create;
begin
  inherited Create;

  // cria uma instancia de controller
  FController := TApiController.Create;

  FServer := TFPHTTPServer.Create(nil);
  FServer.Port := 8080;
  FServer.Threaded := True;
  FServer.OnRequest := @HandleRequest;
end;

destructor THttpServer.Destroy;
begin
  Stop;
  FServer.Free;
  FController.Free;

  inherited Destroy;
end;

procedure THttpServer.Start;
begin
  FServer.Active := True;
end;

procedure THttpServer.Stop;
begin
  if FServer.Active then
    FServer.Active := False;
end;

procedure THttpServer.HandleRequest(Sender: TObject;
  var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse);
begin

  FController.HandleRequest( ARequest, AResponse );

end;

end.

