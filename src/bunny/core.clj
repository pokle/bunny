(ns bunny.core)

(defn elmerfudd [{host :host user :user pass :pass}]
  (let [cf   (com.rabbitmq.client.ConnectionFactory.)
        _    (.setHost cf host)
        _    (.setUsername cf user)
        _    (.setPassword cf pass)
        conn (.newConnection cf)
        chan (.createChannel conn)]
      chan))

(defn publish [chan queue message]
  (.queueDeclare chan queue true false false nil)
  (.basicPublish chan "" queue nil (.getBytes message))
  (println "Published" message))

(defn close-connection [chan]
  (.close (.getConnection chan)))

(defn blast [times]
  (let [ch (elmerfudd {:host "bunny1" :user "bunny" :pass "wabbit"})]
    (dotimes [i times]
      (Thread/sleep 250)
      (publish ch "hole" (str "I'm a happy wabbit" i)))))

#_(future
  (def ch2 (elmerfudd {:host "bunny" :user "bunny" :pass "wabbit"}))
  (def qc (com.rabbitmq.client.QueueingConsumer. ch2))
  (.basicConsume ch2 "hole" true qc)
  (while true
    (println "Message from the ether: "(-> qc .nextDelivery .getBody String.))))


(defn- main [& args]
  (println "blasting...")
  (blast 100)
  (println "Blasted 100"))
