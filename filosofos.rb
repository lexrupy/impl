require 'mutex_m'

# Define a classe de um filosofo 
class Filosofo
  # Metodo construtor, recebe o nome do filosofo e os garfos que ele deve pegar
  def initialize(name, garfo_esquerda, garfo_direita)
    # Define o nome a variavel de instancia
    @name = name
    # Determina os garfos
    @garfo_esquerda = garfo_esquerda
    @garfo_direita = garfo_direita
    # Inicializa o numero de refeicoes que o filosofo ja realisou em 0
    @refeicoes = 0
  end
 
  # Vai, inicie a jornada de pensamento e comilanca do filosofo
  def go
    # Limite a 5 refeicoes
    # Enquanto o numero de refeicoes nao chegar a 5 faca
    while @refeicoes < 5
      # Pensar um pouco
      pensar
      # Ir jantar
      jantar
    end
    # Informa que o filosofo esta satisfeito apos o jantar
    puts "filósofo #@name está satisfeito!"
  end
 
  # Coloca o Filosofo para pensar durante algum tempo
  def pensar
    # Informa que o filosofo esta indo pensar
    puts "filósofo #@name está pensando..."
    # Pensa por algum tempo....
    sleep(rand()*5)
    # Pensar da fome, informa que o filosofo esta agora com fome
    puts "filósofo #@name está com fome..."
  end
 
  # Coloca o filosofo para jantar
  def jantar
    # Indica quais garfos o filosofo deve pegar
    #   Observe que cada filosofo tem seu lugar (prado) e possiveis
    #   garfos pre-definidos
    garfo1, garfo2 = @garfo_esquerda, @garfo_direita
    # Vai tentando
    while true # laco
      # Tenta pegar o primeiro garfo (indicando que vai esperar caso o garfo esteja ocupado
      # por outro filosofo)
      pegar(garfo1, :wait => true)
      # Informa que o garfo foi pego
      puts "filósofo #@name pegou o garfo #{garfo1.garfo_id}..."
      # Tenta pegar o segundo garfo, mas desta vez nao espera caso esteja ocupado
      if pegar(garfo2, :wait => false)
        # Se pegou o segundo garfo, encerra o laco
        break
      end
      # Se nao encerrou o laco e porque nao conseguiu pegar o segundo garfo
      # logo, informa que o segundo garfo nao pode ser pego
      puts "filósofo #@name não pode pegar o segundo garfo #{garfo2.garfo_id}..."
      # Solta o garfo
      soltar(garfo1)
      # Inverte os garfos e começa tudo novamente
      garfo1, garfo2 = garfo2, garfo1
    end
    # Se saiu do laco (loop) anterior, e porque pegou dois garfos, logo
    # informa sobre ter pego o segundo garfo
    puts "filósofo #@name pegou o segundo garfo #{garfo2.garfo_id}..."
    # Informa que agora o Filosofo esta jantando
    puts "filósofo #@name comendo..."
    # come por alguns instantes
    sleep(rand()*5)
    # Filosofo para de comer 
    puts "filósofo #@name para de comer"
    # Incrementa o numero de refeicoes que ele ja fez
    @refeicoes += 1
    # Solta ambos os garfos
    soltar(@garfo_esquerda)
    soltar(@garfo_direita)
  end
 
  # Pegar o garfo
  def pegar(garfo, opt)
    # Informa sobre a tentativa de pegar o garfo
    puts "filósofo #@name tenta pegar o garfo #{garfo.garfo_id}..."
    # Caso seja para aguardar o garfo ficar disponivel, chama
    # o metodo mu_lock (Bloqueio aguardando o recurso ficar disponivel)
    # caso contrario  executa mu_try_lock (Tenta Bloquear o recurso, mas se nao
    # conseguir, desiste e tenta mais tarde)
    opt[:wait] ? garfo.mutex.mu_lock : garfo.mutex.mu_try_lock
  end
 
  # Soltar o garfo
  def soltar(garfo)
    # Informa que o filosofo ira soltar o garfo, para que outros possao usa-lo
    puts "filósofo #@name solta o garfo #{garfo.garfo_id}..."
    # Solta o garfo (desbloqueia o acesso a ele)
    garfo.mutex.unlock
  end
end

# Numero de filosofos 
n = 5

# Define uma classe aberta, Garfo com base em uma estrutura aberta
Garfo = Struct.new(:garfo_id, :mutex)

# Cria os objetos que definem os garfos, mesmo numero de Garfos, quanto
# de filosofos
garfos = Array.new(n) {|i| Garfo.new(i, Object.new.extend(Mutex_m))}
# Cria os objetos representando os filosofos
filosofos = Array.new(n) do |i|
  # Para cada i, crie um filosofo(i), atribuindo-lhe o garfo(i)
  # juntamente com o garfo((i+1)%n), onde % é o modulo (resto da divisao)
  # que ambos indicam, o garfo da esquerda e da direita
  Thread.new(i, garfos[i], garfos[(i+1)%n]) do |id, f1, f2|
    # Cria o Filosofo dentro do contexto da thread, chamando seu
    # metodo de execucao, que o levara a pensar e comer
    ph = Filosofo.new(id, f1, f2).go
  end
end

# Percorre a lista de threads (filosofos) e juntao o processamento
# com a thread principal
filosofos.each {|thread| thread.join}