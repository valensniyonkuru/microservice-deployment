import { HttpStatus, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { CreateOrderDto } from 'src/dtos';
import { Order } from 'src/entities/order.entity';
import { Repository } from 'typeorm';

@Injectable()
export class OrderService {

     constructor (
        @InjectRepository(Order)
        private readonly  orderRepository: Repository<Order>,
    ){}


    async createOrder(createOrderDto: CreateOrderDto){
        const {bookId,customerId,totalPrice,quantity}= createOrderDto

        const order= createOrderDto.id  ?
         this.orderRepository.create({
            id:createOrderDto.id,
            customerId,
            totalPrice,
            bookId,
            quantity}) :
         this.orderRepository.create({
            bookId,
            customerId,
            totalPrice,
            quantity
         })

         await this.orderRepository.save(order)
         return order
    }


    async getOrder(orderId: string) : Promise<Order> {
        try{

            const order= await this.orderRepository.findOne({
                where:{
                    id: orderId
                }
            })
            if (!order){
                throw new NotFoundException("Order not found")
            }
            return order
        }
        catch(error:any){
            console.log(error)
        }
    }

    async deleteOrder (orderId: string) : Promise<{statusCode: HttpStatus, message: string}>{
        try {
            const order= await this.orderRepository.findOne({
                where:{
                    id: orderId
                }
            })
            if(!order){
                throw new NotFoundException("Order not found")
            }
            await this.orderRepository.delete(order);

            return {
                statusCode: HttpStatus.OK,
                message: "Order deleted successfully"
            }
        } catch (error) {
           console.log(error)
        }
    }
    
}
