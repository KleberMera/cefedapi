import {config} from "dotenv";
config();
export const BD_HOST = process.env.BD_HOST || localhost;
export const BD_DATABASE = process.env.BD_DATABASE || db_curso20242;
export const BD_USER = process.env.BD_USER || root;
export const BD_PASS = process.env.BD_PASS || "";
export const BD_PORT = process.env.BD_PORT || 3306;
export const PORT = process.env.PORT || 3000;