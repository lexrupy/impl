require 'thread'

# Recurso a ser compartilhado
@recurso = 0
# Lista de threads
@threads = []
# Tempo de espera em Milisegundos, a divisao por 1000 e necessaria pois o padrao e segundos
@sleep_time = 1/1000
# Cria o Semaforo (Mutex => MUTual EXclusion)
@semaforo = Mutex.new
# Numero de threads a serem criadas
n = 20
# de 1 ate N, para cada faca
(1..n).each do
  # Inserir nova thread na lista de threads
  @threads << Thread.new do
    # de 1 ate 100000, para cada faca
    (1..100000).each do
      # Entre na secao critica e faca
      @semaforo.synchronize do
        # Incremente o recurso
        @recurso += 1
        # Soneca....
        sleep(@sleep_time)
      end 
    end 
  end 
end
# Solicita espera
puts "Aguarde..."
# Para cada item na lista de threads, junte a thread t a linha de execucao
@threads.each{|t| t.join}
# Exibe o valor final do recurso
puts @recurso
