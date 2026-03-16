import { User } from 'oidc-client-ts';

export interface UserContext extends User {
  lang: string;
  name: string;
  n_rows: number;
  n_rows_detail: number;
  role: string[];
}
