module Common.Views.Forms
    exposing
        ( Error
        , Input
        , form
        , formButtons
        , formClass
        , formErrors
        , inputField
        )

import Html exposing (Html, button, div, label, li, text, ul)
import Html.Attributes exposing (class, for, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


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


type alias Button msg =
    ( String, msg )


form :
    Button msg
    -> List (Button msg)
    -> List String
    -> List (Input msg)
    -> Html msg
form ( submitText, onSubmit ) otherButtons summaryErrors inputs =
    Html.form
        [ class formClass
        , Html.Events.onSubmit onSubmit
        ]
    <|
        formErrors summaryErrors
            :: List.concatMap inputField inputs
            ++ List.singleton (formButtons submitText otherButtons)


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
    div
        [ class "validation-summary" ]
        [ ul
            [ class "validation-errors" ]
            (List.map errorLineItem errors)
        ]


errorLineItem : String -> Html msg
errorLineItem errorText =
    li
        [ class "validation-error" ]
        [ text errorText ]


formButtons : String -> List (Button msg) -> Html msg
formButtons submitText otherButtons =
    let
        submitButton =
            button [] [ text submitText ]
    in
        div
            [ class "form-buttons" ]
            (submitButton
                :: List.map formButton otherButtons
            )


formButton : Button msg -> Html msg
formButton ( buttonText, action ) =
    button
        [ type_ "button", onClick action ]
        [ text buttonText ]


formClass : String
formClass =
    "simple-form"
