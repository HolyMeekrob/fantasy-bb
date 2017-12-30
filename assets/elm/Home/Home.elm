module Home exposing (..)

import Header.Types
import Header.State
import Header.View
import Html exposing (Html, div, header, program, text)


type alias Model =
    { header : Header.Types.Model
    }


type Msg
    = HeaderMsg Header.Types.Msg


init : ( Model, Cmd Msg )
init =
    let
        model =
            { header = Header.State.initialModel
            }
    in
        model ! [ Cmd.map HeaderMsg Header.State.initialize ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HeaderMsg headerMsg ->
            let
                headerModel =
                    Header.State.update headerMsg model.header
            in
                ( { model | header = headerModel }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div
        []
        [ header
            []
            [ Header.View.view model.header ]
        , div
            []
            [ text "Home page" ]
        ]


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
