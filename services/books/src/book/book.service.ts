import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { CreateBookDto } from 'src/dtos';
import { Book } from 'src/entities/book.entity';
import { Repository } from 'typeorm';

@Injectable()
export class BookService {

    constructor (
        @InjectRepository(Book)
        private readonly bookRepository: Repository<Book>
){}



async addBook (createBookDto: CreateBookDto) : Promise<Book> {
    const {title, author, price, stock}= createBookDto;

    const newBook= await this.bookRepository.create({
         title,
         author,
         price,
         stock
    })
    await this.bookRepository.save(newBook);
    return newBook
}
async getBook (bookId: string) : Promise<Book> {
    try {
        
        const book= await this.bookRepository.findOne({
            where:{
                id: bookId
            }
        
        })
        if(!book) throw new NotFoundException("Book not found")
        return book
    } catch (error) {
        console.log(error);
        
    }

}

async getBooks(): Promise<Book[]>{
    return await this.bookRepository.find()
}

async isBookInStock(bookId: string, quantity: number) : Promise <boolean> {
    const book = await this.bookRepository.findOne({
        where:{
            id:bookId
        }
    })
    return  quantity <= book.stock
}


async decreaseBookStock(bookId: string, quantity: number):  Promise<Book>{
    const book= await this.bookRepository.findOne({
        where:{
            id: bookId
        }
    })

    book.stock -= quantity;
    const updatedBook= await this.bookRepository.save(book);
    return updatedBook;
}

async increaseBookStock(bookId: string, addedQuantity:number): Promise<Book>{
    const book= await this.bookRepository.findOne({
        where:{
            id: bookId
        }
    })

    book.stock += addedQuantity;
    const updatedBook= await this.bookRepository.save(book);
    return updatedBook;
}
}
