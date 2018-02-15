module Season.Create.Rest exposing (createSeason)

import Common.Date exposing (dateToString)
import Season.Create.Types as Types exposing (Model, Msg, Season)
import Http exposing (jsonBody)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode


createSeason : Model -> Cmd Msg
createSeason model =
    let
        url =
            "/ajax/season"

        data =
            Encode.object
                [ ( "title", Encode.string model.title )
                , ( "start"
                  , Encode.string
                        (model.start
                            |> Maybe.map dateToString
                            |> Maybe.withDefault ""
                        )
                  )
                ]
                |> jsonBody
    in
        Http.post url data seasonDecoder
            |> Http.send Types.SeasonCreated


seasonDecoder : Decoder Season
seasonDecoder =
    decode Season
        |> required "id" Decode.int
        |> required "title" Decode.string
        |> required "start" Decode.string
