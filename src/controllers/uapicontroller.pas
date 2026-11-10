
unit uApiController;

{$mode objfpc}{$H+}

interface

uses
  fphttpserver;

type
  TApiController = class
  public
    procedure HandleRequest(
      var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse
    );
  end;

implementation

uses
  SysUtils,
  fpjson,
  uCepService,
  uEndereco;

procedure ResponderErro(
  AResponse: TFPHTTPConnectionResponse;
  Codigo: Integer;
  const Mensagem: string
);
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.Add('erro', Mensagem);

    AResponse.Code := Codigo;
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.Content := JSON.AsJSON;
  finally
    JSON.Free;
  end;
end;

procedure TApiController.HandleRequest(
  var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse
);
var
  CEP: string;
  Endereco: TEndereco;
  JSON: TJSONObject;
begin
  AResponse.ContentType := 'application/json; charset=utf-8';

  // Aceita somente requisições GET
  if ARequest.Method <> 'GET' then
  begin
    ResponderErro(AResponse, 405, 'Método não permitido.');
    Exit;
  end;

  // Endpoint de verificação
  if ARequest.PathInfo = '/health' then
  begin
    JSON := TJSONObject.Create;
    try
      JSON.Add('status', 'online');
      JSON.Add('message', 'API CEP funcionando!');

      AResponse.Code := 200;
      AResponse.Content := JSON.AsJSON;
    finally
      JSON.Free;
    end;

    Exit;
  end;

  // Endpoint de consulta de CEP
  if Pos('/cep/', ARequest.PathInfo) = 1 then
  begin
    //'/cep/12240000' copia a partir da sexta posição
    CEP := Copy(ARequest.PathInfo, 6, Length(ARequest.PathInfo));

    Endereco := nil;

    try
      //consultando o serviço viacep e devolce um objeto TEndereco
      Endereco := TCepService.ConsultarCEP(CEP);

      JSON := TJSONObject.Create;
      try
        //pegando os dados do objeto TEndereco e transformando em JSON.
        JSON.Add('cep', Endereco.Cep);
        JSON.Add('logradouro', Endereco.Logradouro);
        JSON.Add('complemento', Endereco.Complemento);
        JSON.Add('bairro', Endereco.Bairro);
        JSON.Add('localidade', Endereco.Localidade);
        JSON.Add('uf', Endereco.UF);
        JSON.Add('ibge', Endereco.IBGE);

        AResponse.Code := 200;
        AResponse.Content := JSON.AsJSON;
      finally
        JSON.Free;
      end;

    except
      on E: ECEPInvalido do
        ResponderErro(AResponse, 400, E.Message);

      on E: ECEPnaoEncontrado do
        ResponderErro(AResponse, 404, E.Message);

      on E: EConsultaCEP do
        ResponderErro(AResponse, 502, E.Message);

      on E: Exception do
        ResponderErro(AResponse, 500, 'Erro interno do servidor.');
    end;

    Endereco.Free;
    Exit;
  end;

  // Rota não encontrada
  ResponderErro(AResponse, 404, 'Rota não encontrada.');
end;

end.

