import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Customer } from 'src/entities/customer.entity';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';

@Module({
  providers: [AuthService],
  controllers: [AuthController],
  imports:[
    PassportModule,
    JwtModule.register({
    secret:process.env.JWT_SECRET_KEY,
    signOptions:{expiresIn:'2d'}
  }),
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
  ]),
  TypeOrmModule.forFeature([Customer])
  ]
})
export class AuthModule {}
