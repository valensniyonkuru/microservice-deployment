import { ConfigService } from "@nestjs/config";
import { PassportStrategy } from "@nestjs/passport";
import { ExtractJwt, Strategy } from "passport-jwt";
import { TokenPayload } from "types";


export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly configService: ConfigService){
    super({
          jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
          secretOrKey: process.env.JWT_SECRET_KEY
    })
  }

  async validate(payload: TokenPayload) {
   return {id:payload.sub, email: payload.email}      
  }

  
}