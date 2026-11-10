unit uEndereco;

{$mode ObjFPC}{$H+}

interface

type
  TEndereco = class
  private

    FCep: string;
    FLogradouro: string;
    FComplemento: string;
    FBairro: string;
    FLocalidade: string;
    FUF: string;
    FIBGE: string;

  public

    property Cep: string read FCep write FCep;
    property Logradouro: string read FLogradouro write FLogradouro;
    property Complemento: string read FComplemento write FComplemento;
    property Bairro: string read FBairro write FBairro;
    property Localidade: string read FLocalidade write FLocalidade;
    property UF: string read FUF write FUF;
    property IBGE: string read FIBGE write FIBGE;

  end;

implementation

end.

