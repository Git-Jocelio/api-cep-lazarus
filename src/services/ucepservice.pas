unit uCepService;

{$mode ObjFPC}{$H+}

interface

uses
  uEndereco, SysUtils;

type

  ECEPInvalido = class(Exception);
  ECEPnaoEncontrado = class(Exception);
  EConsultaCEP = class(Exception);


  TCepService = class
  public
    class function ConsultarCEP(const ACep: string): TEndereco;
  end;

implementation
uses
  fpjson, //fornece as classes para trabalhar com objetos e valores JSON.
  fphttpclient, //biblioteca responsável por fazer requisições HTTP e HTTPS para outros servidores.
  opensslsockets,  //necessário para habilitar a comunicação HTTPS no Free Pascal.
  jsonparser;  //fornece o analisador que transforma o texto JSON em objetos manipuláveis.

function ValorCampo(AJSON : TJSONObject; const Nome: string): string;
var
  Campo: TJSONData;
begin
  Campo:= AJSON.Find(Nome);

  if (Campo = nil) or (Campo.JSONType = jtNull) then
    Result := ''
  else
    Result := Campo.AsString
      ;
end;

function SomenteNumeros(const Valor: string): string;
var
  I: integer;
begin
  Result := '';

  for I := 1 to Length(Valor) do
    if (Valor[I] >= '0') and (Valor[I] <= '9') then
      Result := Result + Valor[I];
end;

class function TCepService.ConsultarCEP(const ACep: string): TEndereco;
var
  CEP: string;
  URL: string;
  Resposta: string;
  DadosJSON: TJSONData;
  ObjetoJSON: TJSONObject;
  ClienteHTTP: TFPHTTPClient;
  CampoErro: TJSONData;
begin
  Result := nil;
  // validar cep
  CEP:= SomenteNumeros(ACep);

  if Length(CEP) <> 8 then
    raise ECEPInvalido.Create('O CEP deve possuir 8 números.');

  ClienteHTTP:= TFPHTTPClient.Create(nil);

  try
    URL:='http://viacep.com.br/ws/' + CEP + '/json/';

    try
      Resposta:= ClienteHTTP.Get(URL);

    except
      on E: Exception do
        raise EConsultaCEP.Create('Não foi possível consultar o ViaCEP: ' + E.Message);
    end;

    DadosJSON := GetJSON(Resposta);
    try
      if not (DadosJSON is TJSONObject) then
        raise EConsultaCEP.Create('Resposta inválida do ViaCep');

      ObjetoJSON := TJSONObject(DadosJSON);

      CampoErro := ObjetoJSON.Find('erro');

      if (CampoErro <> nil) and
         (CampoErro.JSONType = jtBoolean) and
         CampoErro.AsBoolean then
       raise ECEPnaoEncontrado.Create('CEP não encontrado.');



      Result := TEndereco.Create;

      Result.Cep:= ValorCampo(ObjetoJSON, 'cep');
      Result.Logradouro:= ValorCampo(ObjetoJSON, 'logradouro');;
      Result.Complemento:= ValorCampo(ObjetoJSON, 'complemento');;
      Result.Bairro:= ValorCampo(ObjetoJSON, 'bairro');;
      Result.Localidade:= ValorCampo(ObjetoJSON, 'localidade');;
      Result.UF:= ValorCampo(ObjetoJSON, 'uf');;
      Result.IBGE:= ValorCampo(ObjetoJSON, 'ibge');;

    finally
      DadosJSON.Free;
    end;



  finally
    ClienteHTTP.Free;
  end;

end;
end.

