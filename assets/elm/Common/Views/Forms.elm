module Common.Views.Forms exposing (Input, form)

import Html exposing (Html, button, div, label, text)
import Html.Attributes exposing (class, for, id, placeholder, type_, value)
import Html.Events exposing (onInput)


type alias Input msg =
    { id : String
    , type_ : String
    , label : String
    , placeholder : String
    , value : String
    , onInput : String -> msg
    }


form : msg -> String -> List (Input msg) -> Html msg
form onSubmit submitText inputs =
    Html.form
        [ class "simple-form"
        , Html.Events.onSubmit onSubmit
        ]
    <|
        List.concatMap inputField inputs
            ++ [ button
                    [ class "form-submit" ]
                    [ text submitText ]
               ]


inputField : Input msg -> List (Html msg)
inputField input =
    [ div
        [ class "form-label" ]
        [ label
            [ for input.id ]
            [ text input.label ]
        ]
    , div
        [ class "form-input" ]
        [ Html.input
            [ type_ input.type_
            , id input.id
            , placeholder input.placeholder
            , value input.value
            , onInput input.onInput
            ]
            []
        ]
    ]
