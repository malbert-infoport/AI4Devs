export enum Access {
  // Core security options (from SQL)
  'User customization' = 1,
  'Profile query' = 2,
  'Profile modification' = 3,
  'General company configuration query' = 4,
  'General company configuration modification' = 5,

  // Organization access options (from 01000002_SecurityData.sql)
  'Organization query' = 200,
  'Organization modification' = 201,
  'Organization modules query' = 202,
  'Organization audit query' = 203,
  'Organization modules modification' = 204,

  // Application access options (from 01000002_SecurityData.sql)
  'Application data query' = 300,
  'Application data modification' = 301,
  'Application modules query' = 302,
  'Application modules modification' = 303,
  'Application roles query' = 304,
  'Application roles modification' = 305,
  'Application credentials query' = 306,
  'Application credentials modification' = 307,
  'Application audit query' = 308
}
