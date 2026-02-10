import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import { BookService } from './book.service';
import { EventPattern, MessagePattern, Payload } from '@nestjs/microservices';
import { CreateBookDto } from 'src/dtos';

const GET_BOOK="getBook"
const IS_BOOK_IN_STOCK= "isBookInStock"
const INCREASE_STOCK= "increaseStock"
const DECREASE_STOCK= "decreaseStock"

@Controller('book')
export class BookController {
    constructor (private readonly bookService: BookService){}

    @MessagePattern(GET_BOOK)
    async handleGetBook(@Payload() data: { bookId: string}){
        const  {bookId}= data

        return await this.bookService.getBook(bookId)

    }

    @MessagePattern(IS_BOOK_IN_STOCK)
    async handleIsBookInStock(@Payload() data: {bookId: string, quantity:number}): Promise<boolean>{
        const {bookId,quantity}= data;
        return await this.bookService.isBookInStock(bookId,quantity)

    }

    @EventPattern(DECREASE_STOCK)
    async handleDecreaseStock(@Payload() data: {bookId: string, quantity: number}){
        const {bookId,quantity}= data;
        return await this.bookService.decreaseBookStock(bookId,quantity)
    }

    @Post("/new")
    async handleAddBook(@Body() createBookDto: CreateBookDto){
        return await this.bookService.addBook(createBookDto);
    }

    

    @Patch("/:id")
    async handleIncreaseStock(@Param("id") bookId: string, @Body()  quantity: number){
        return await this.bookService.increaseBookStock(bookId,quantity);
    }

}
