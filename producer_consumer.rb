require 'monitor'

# Tamanho do buffer
N = 10

# Buffer representado por um array
BUFFER = []#Array.new(N)


class ProdutorConsumidor < Monitor
  # Metodo construtor, inicializando o @total de itens em 0
  def initialize
    @total = 0
    super
  end

  # Produz um item
  # Recebe o item a ser produzido como parametro
  def produzir(item)
    # Entra na seção crítica
    synchronize do
      # Verifica se já alcancou o total de itens suportado pelo buffer
      if @total == N
        # Informa que nao ha mais espaco no buffer
        puts "Estoque lotado!"
        # Passa o controle para a proxima thread
        Thread.pass
      else
        # Produzir item, e adicionar no buffer
        inserir_item(item)
        # Informar sobre a producao do item
        puts "Item produzido #{item}"
        # Incrementar o total de itens
        @total += 1
      end
    end
    # print_buffer
  end

  # Consome um item do buffer
  def consumir
    # Entra na secao critica
    synchronize do
      # Verifica se o Buffer nao esta vazio
      if @total == 0
        # Informa que nao ha itens no buffer
        puts "Nada para consumir!"
        # Passa o controle para a proxima thread
        Thread.pass
      else
        # Remove o item do buffer para consumo
        p = remover_item
        # Informa que o item foi consumido
        puts "Iten consumido #{p}"
        # Decrementa a contagem
        @total -= 1
      end
    end
    # print_buffer
  end

  private
  
  # Insere um item produzido no buffer
  def inserir_item(item)
    # Insere um item no inicio do buffer
    BUFFER.unshift item
  end

  # Remover um item para consumo
  def remover_item
    # Remove um item do final do buffer
    BUFFER.pop
  end
  
  # Apenas para debug
  def print_buffer
    puts "[#{BUFFER.join(',')}]"
  end
end

# Cria uma instancia da classe de producao/consumo
pc = ProdutorConsumidor.new

# Listas de Produtores e Consumidores
@produtores = []
@consumidores = []

# Cria X Produtores cada um em uma thread separada
4.times { @produtores << Thread.new { loop { pc.produzir(rand(50)); sleep(rand); } } }
# Cria X Consumidores, cada um em sua thread
3.times { @consumidores << Thread.new { loop { pc.consumir; sleep(rand); } } }

# Anexa as threads na thread principal 
@produtores.each { |p| p.join }
@consumidores.each { |c| c.join }
# Pronto!

# Apenas para facilitar a leitura, a  lista de produtores poderia ser inicializada deste modo:
# 1.times do
#   @produtores << Thread.new do
#     loop do
#       pc.produzir(rand(50))
#       sleep(rand)
#     end
#   end
# end