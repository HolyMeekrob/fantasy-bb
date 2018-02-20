module Common.Views.Forms exposing (Error, Input, form)

import Html exposing (Html, button, div, label, li, text, ul)
import Html.Attributes exposing (class, for, id, placeholder, type_, value)
import Html.Events exposing (onInput)

type alias Error a =
    ( a, String )

type alias Input msg =
    { id : String
    , type_ : String
    , label : String
    , placeholder : String
    , value : String
    , onInput : String -> msg
    , isRequired : Bool
    , errors : List String
    }


form : msg -> String -> List String -> List (Input msg) -> Html msg
form onSubmit submitText summaryErrors inputs =
    Html.form
        [ class "simple-form"
        , Html.Events.onSubmit onSubmit
        ]
    <|
        div
            [ class "validation-summary" ]
            [ formErrors summaryErrors ]
            :: List.concatMap inputField inputs
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
            [ text (inputLabel input) ]
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
    , formErrors input.errors
    ]


inputLabel : Input msg -> String
inputLabel input =
    if input.isRequired then
        input.label ++ "*"
    else
        input.label


formErrors : List String -> Html msg
formErrors errors =
    ul
        [ class "validation-errors" ]
        (List.map errorLineItem errors)


errorLineItem : String -> Html msg
errorLineItem errorText =
    li
        [ class "validation-error" ]
        [ text errorText ]
