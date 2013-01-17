class Cieloz::RequisicaoTransacao < Cieloz::Base
  class DadosPortador
    include Cieloz::Helpers

    attr_accessor :numero, :nome_portador, :validade, :codigo_seguranca
    attr_reader :indicador

    def indicador
      1
    end

    def attributes
      {
        numero:           @numero,
        validade:         @validade,
        indicador:        indicador,
        codigo_seguranca: @codigo_seguranca,
        nome_portador:    @nome_portador
      }
    end

    TEST_VISA   = new numero: 4012001037141112,
      validade: 201805, codigo_seguranca: 123
    TEST_MC     = new numero: 5453010000066167,
      validade: 201805, codigo_seguranca: 123
    TEST_VISA_NO_AUTH =
      new numero: 4012001038443335,
      validade: 201805, codigo_seguranca: 123
    TEST_MC_NO_AUTH =
      new numero: 5453010000066167,
      validade: 201805, codigo_seguranca: 123
    TEST_AMEX   = new numero: 376449047333005,
      validade: 201805, codigo_seguranca: 1234
    TEST_ELO    = new numero: 6362970000457013,
      validade: 201805, codigo_seguranca: 123
    TEST_DINERS = new numero: 36490102462661,
      validade: 201805, codigo_seguranca: 123
    TEST_DISC   = new numero: 6011020000245045,
      validade: 201805, codigo_seguranca: 123
  end

  class DadosPedido
    include Cieloz::Helpers

    attr_accessor :numero, :valor, :moeda, :data_hora, :descricao, :idioma, :soft_descriptor

    def attributes
      {
        numero:           @numero,
        valor:            @valor,
        moeda:            @moeda,
        data_hora:        @data_hora.strftime("%Y-%m-%dT%H:%M:%S"),
        descricao:        @descricao,
        idioma:           @idioma,
        soft_descriptor:  @soft_descriptor
      }
    end
  end

  class FormaPagamento
    include Cieloz::Helpers

    attr_accessor :bandeira
    attr_reader :produto, :parcelas

    def attributes
      {
        bandeira: @bandeira,
        produto:  @produto,
        parcelas: @parcelas
      }
    end

    def debito
      if @bandeira == Cieloz::Bandeiras::VISA || @bandeira == Cieloz::Bandeiras::MASTERCARD
        @produto  = "A"
        @parcelas = 1
      else
        raise "Operacao de debito disponivel apenas para VISA e MasterCard"
      end
    end

    def credito_a_vista
      @produto  = 1
      @parcelas = 1
    end

    def parcelado_loja parcelas
      raise "Parcelas invalidas: #{parcelas}" if parcelas.to_i <= 0
      raise "Nao suportado pela bandeira DISCOVER" if @bandeira == Cieloz::Bandeiras::DISCOVER
      if parcelas == 1
        credito_a_vista
      else
        @produto  = 2
        @parcelas = parcelas
      end
    end

    def parcelado_adm parcelas
      raise "Parcelas invalidas: #{parcelas}" if parcelas.to_i <= 0
      raise "Nao suportado pela bandeira DISCOVER" if @bandeira == Cieloz::Bandeiras::DISCOVER
      if parcelas == 1
        credito_a_vista
      else
        @produto  = 3
        @parcelas = parcelas
      end
    end
  end

  SOMENTE_AUTENTICAR        = 0
  AUTORIZAR_SE_AUTENTICADA  = 1
  AUTORIZAR_NAO_AUTENTICADA = 2
  AUTORIZACAO_DIRETA        = 3
  RECORRENTE                = 4

  hattr_writer :dados_portador
  hattr_writer :dados_pedido, :forma_pagamento

  attr_accessor :campo_livre, :url_retorno
  attr_reader :autorizar
  attr_reader :capturar

  def somente_autenticar
    @autorizar = SOMENTE_AUTENTICAR
  end

  def requer_autenticacao
    @autorizar = AUTORIZAR_SE_AUTENTICADA
  end

  def nao_requer_autenticacao
    @autorizar = AUTORIZAR_NAO_AUTENTICADA
  end

  def autorizacao_direta
    @autorizar = AUTORIZACAO_DIRETA
  end

  def recorrente
    @autorizar = RECORRENTE
  end

  def capturar_automaticamente
    @capturar = true
  end

  def nao_capturar_automaticamente
    @capturar = false
  end

  def attributes
    {
      dados_ec:         @dados_ec,
      dados_portador:   @dados_portador,
      dados_pedido:     @dados_pedido,
      forma_pagamento:  @forma_pagamento,
      url_retorno:      @url_retorno,
      autorizar:        @autorizar,
      capturar:         @capturar,
      campo_livre:      @campo_livre
    }
  end
end