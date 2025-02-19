package main

import (
	"fmt"
	cronsumer "github.com/Trendyol/kafka-cronsumer"
	"github.com/Trendyol/kafka-cronsumer/pkg/kafka"
	"time"
)

func main() {
	config := &kafka.Config{
		Brokers: []string{"localhost:29092"},
		Consumer: kafka.ConsumerConfig{
			GroupID:  "sample-consumer-with-producer",
			Topic:    "exception",
			MaxRetry: 3,
			Cron:     "*/1 * * * *",
			Duration: 20 * time.Second,
		},
		LogLevel: "info",
	}

	var consumeFn kafka.ConsumeFn = func(message kafka.Message) error {
		fmt.Printf("consumer > Message received: %s\n", string(message.Value))
		return nil
	}

	c := cronsumer.New(config, consumeFn)
	c.Start()

	// If we want to produce a message to exception topic
	message := kafka.NewMessageBuilder().
		WithTopic(config.Consumer.Topic).
		WithKey(nil).
		WithValue([]byte(`{ "foo": "bar" }`)).
		Build()
	c.Produce(message)

	select {} // showing purpose
}
