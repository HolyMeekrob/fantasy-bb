module Leagues.Create.View exposing (view)

import Common.Views exposing (empty, layout, loading, title)
import Common.Views.Forms
    exposing
        ( formButtons
        , formClass
        , formErrors
        , inputField
        )
import Header.View exposing (headerView)
import Html exposing (Html, div, form, option, section, select, text)
import Html.Attributes exposing (class, selected, value)
import Html.Events exposing (onInput, onSubmit)
import Leagues.Create.Types as Types exposing (FormField, Model, Msg, Season)
import List.Extra exposing (find)


view : Model -> Html Msg
view model =
    layout
        (headerView Types.HeaderMsg model.header)
        (primaryView model)


primaryView : Model -> Html Msg
primaryView model =
    section
        []
        [ loadingOverlay model
        , title "Create League"
        , content model
        ]


content : Model -> Html Msg
content model =
    case model.pageState of
        Types.Error errorMsg ->
            errorView errorMsg

        _ ->
            standardView model


errorView : String -> Html Msg
errorView errorMsg =
    div
        [ class "error" ]
        [ text errorMsg ]


standardView : Model -> Html Msg
standardView model =
    let
        nameField =
            { id = "league-name"
            , type_ = "text"
            , label = "League Name"
            , placeholder = "League name"
            , value = model.name
            , onInput = Types.SetName
            , isRequired = True
            , errors = errors Types.Name model
            }
    in
        div
            []
            [ form
                [ class formClass
                , onSubmit Types.SubmitForm
                ]
              <|
                formErrors (errors Types.Summary model)
                    :: inputField nameField
                    ++ List.singleton (selectSeason model)
                    ++ List.singleton (formButtons "Create" [])
            ]


selectSeason : Model -> Html Msg
selectSeason model =
    if (List.length model.possibleSeasons == 1) then
        empty
    else
        div
            []
            [ select
                [ onInput (updateSelectedSeason model) ]
              <|
                (defaultSeason model)
                    :: List.map (seasonOption model) model.possibleSeasons
            ]


defaultSeason : Model -> Html Msg
defaultSeason model =
    option
        [ value "N/A"
        , selected (model.season == Nothing)
        ]
        [ text "Select a season" ]


seasonOption : Model -> Season -> Html Msg
seasonOption model season =
    let
        isSelected =
            case model.season of
                Nothing ->
                    False

                Just selectedSeason ->
                    season.id == selectedSeason.id
    in
        option
            [ value (toString season.id)
            , selected isSelected
            ]
            [ text season.title ]


loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading

        _ ->
            empty


errors : FormField -> Model -> List String
errors field model =
    let
        fieldMatches =
            \( errorField, _ ) -> field == errorField
    in
        List.filter fieldMatches model.errors
            |> List.map Tuple.second


getSeason : Model -> Int -> Maybe Season
getSeason model id =
    find
        (\season -> season.id == id)
        model.possibleSeasons


updateSelectedSeason : Model -> String -> Msg
updateSelectedSeason model val =
    String.toInt val
        |> Result.toMaybe
        |> Maybe.andThen (getSeason model)
        |> Types.SetSelectedSeason
