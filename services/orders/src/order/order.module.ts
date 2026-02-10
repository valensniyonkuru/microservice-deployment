import { Module } from '@nestjs/common';
import { OrderService } from './order.service';
import { OrderController } from './order.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Order } from 'src/entities/order.entity';
import { ClientsModule, Transport } from '@nestjs/microservices';
@Module({
  providers: [OrderService],
  controllers: [OrderController],
  imports:[TypeOrmModule.forFeature([Order]),
  ClientsModule.register([
    {
        name: "BOOK_SERVICE",
         transport: Transport.RMQ,
         options: {
            urls: [process.env.RABBITMQ_URL],
            queue: "book_queue",
            queueOptions:{
                durable: true
            }
         }
    },
    {
        name: "ORDER_SERVICE",
        transport: Transport.RMQ,
        options:{
            urls:[process.env.RABBITMQ_URL],
            queue:"order_queue",
            queueOptions:{
                durable: false
            }
        }
    },
    {
        name: "CUSTOMER_SERVICE",
        transport: Transport.RMQ,
        options:{
            urls:[process.env.RABBITMQ_URL],
            queue:"customer_queue",
            queueOptions:{
                durable: false
            }
        }
    }
])

],
  exports:[OrderService]
})
export class OrderModule {}
