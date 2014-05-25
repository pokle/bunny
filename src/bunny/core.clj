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

(def ch1 (elmerfudd {:host "bunny1.mq" :user "bunny" :pass "wabbit"}))

(prn (dotimes [i 100]
          (Thread/sleep 250)
          (publish ch1 "hole" (str "I'm a happy wabbit" i))))

#_(future
  (def ch2 (elmerfudd {:host "bunny2.mq" :user "bunny" :pass "wabbit"}))
  (def qc (com.rabbitmq.client.QueueingConsumer. ch2))
  (.basicConsume ch2 "hole" true qc)
  (while true
    (println "Message from the ether: "(-> qc .nextDelivery .getBody String.))))
