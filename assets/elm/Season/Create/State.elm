module Season.Create.State exposing (init, subscriptions, update)

import Season.Create.Types as Types exposing (Model, Msg)
import Header.State


initialModel : Model
initialModel =
    { header = Header.State.initialModel
    , name = ""
    }


init : ( Model, Cmd Msg )
init =
    initialModel ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Types.HeaderMsg headerMsg ->
            let
                ( headerModel, headerCmd ) =
                    Header.State.update headerMsg model.header
            in
                { model | header = headerModel }
                    ! [ Cmd.map Types.HeaderMsg headerCmd ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
