module Home.State exposing (init, update, subscriptions)

import Header.State
import Home.Rest exposing (fetchUser)
import Home.Types as Types exposing (Model, Msg)


init : ( Model, Cmd Msg )
init =
    let
        model =
            { header = Header.State.initialModel
            }
    in
        ( model, fetchUser )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Types.HeaderMsg headerMsg ->
            let
                ( headerModel, headerCmd ) =
                    Header.State.update headerMsg model.header
            in
                ( { model | header = headerModel }
                , Cmd.map Types.HeaderMsg headerCmd
                )

        Types.SetUser (Err _) ->
            { model | header = Nothing } ! []

        Types.SetUser (Ok user) ->
            { model | header = Just user } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
