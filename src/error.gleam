import gleam/httpc
import gleam/json
import pog

pub type DatabaseError {
  NoRecordsFoundError
  QueryError(pog.QueryError)
}

pub type HttpError {
  HttpcError(httpc.HttpError)
  JsonDecodingError(json.DecodeError)
}
