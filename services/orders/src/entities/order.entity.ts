import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";


@Entity()
export class Order{

    @PrimaryGeneratedColumn("uuid")
    id: string;


    @Column()
    customerId: string;

    @Column()
    bookId: string;

    @Column()
    quantity: number;

    @Column()
    totalPrice: number;
}