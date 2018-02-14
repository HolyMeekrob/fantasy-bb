module Season.Create.View exposing (view)

import Season.Create.Types as Types exposing (FormField, Model, Msg)
import Common.Views exposing (layout, showMaybeDate)
import Common.Views.Forms exposing (form)
import Header.View exposing (headerView)
import Html exposing (Html, div, h1, section, text)
import Html.Attributes exposing (class)


view : Model -> Html Msg
view model =
    layout
        (headerView Types.HeaderMsg model.header)
        (primaryView model)


primaryView : Model -> Html Msg
primaryView model =
    section
        []
        [ h1
            [ class "page-title" ]
            [ text "Create Season" ]
        , div
            []
            [ form
                Types.SubmitForm
                "Submit"
                [ { id = "season-name"
                  , type_ = "text"
                  , label = "Name"
                  , placeholder = "Season name"
                  , value = model.name
                  , onInput = Types.SetName
                  , isRequired = True
                  , errors = errors Types.Name model
                  }
                , { id = "season-start"
                  , type_ = "date"
                  , label = "Start date"
                  , placeholder = "Season start date"
                  , value = showMaybeDate model.start
                  , onInput = Types.SetStart
                  , isRequired = True
                  , errors = errors Types.Start model
                  }
                ]
            ]
        ]


errors : FormField -> Model -> List String
errors field model =
    let
        fieldMatches =
            \( errorField, _ ) -> field == errorField
    in
        List.filter fieldMatches model.errors
            |> List.map Tuple.second
