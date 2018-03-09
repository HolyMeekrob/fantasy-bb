module Seasons.Show.View exposing (view)

import Common.Date exposing (dateToString)
import Common.Views exposing (empty, layout, loading, titleWithEdit)
import Common.Views.Forms
    exposing
        ( formButtons
        , formClass
        , formErrors
        , inputField
        )
import Common.Views.Text exposing (playerName)
import Editable exposing (Editable)
import FontAwesome as FA exposing (timesCircle, iconWithOptions)
import Header.View exposing (headerView)
import Html
    exposing
        ( Html
        , a
        , button
        , dd
        , div
        , dl
        , dt
        , form
        , h1
        , li
        , option
        , section
        , select
        , text
        , ul
        )
import Html.Attributes exposing (class, href, selected, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import List.Extra exposing (find)
import Seasons.Show.Types as Types
    exposing
        ( FormField
        , Model
        , Msg
        , Player
        , Season
        , getSeason
        )


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
        , titleWithEdit
            "View Season"
            Types.EditSeason
            (model.userCanEdit && (not <| isEditing model))
        , content model
        ]


content : Model -> Html Msg
content model =
    if (isEditing model) then
        editSeason model
    else
        viewContent model


viewContent : Model -> Html Msg
viewContent model =
    let
        season =
            getSeason model
    in
        div
            []
            [ viewSeason season
            , viewHouseguests season.houseguests
            ]


viewSeason : Season -> Html Msg
viewSeason season =
    div
        []
        [ dl
            []
          <|
            List.concat
                [ showAttribute "Title" season.title
                , showAttribute
                    "Start"
                    (Maybe.map
                        dateToString
                        season.start
                        |> Maybe.withDefault ""
                    )
                ]
        ]


showAttribute : String -> String -> List (Html Msg)
showAttribute title description =
    [ dt
        []
        [ text title ]
    , dd
        []
        [ text description ]
    ]


editSeason : Model -> Html Msg
editSeason model =
    let
        season =
            getSeason model

        titleField =
            { id = "season-title"
            , type_ = "text"
            , label = "Title"
            , placeholder = "Season title"
            , value = season.title
            , onInput = Types.SetTitle
            , isRequired = True
            , errors = errors Types.Title model
            }

        startField =
            { id = "season-start"
            , type_ = "date"
            , label = "Start date"
            , placeholder = "Season start date"
            , value =
                season.start
                    |> Maybe.map dateToString
                    |> Maybe.withDefault ""
            , onInput = Types.SetStart
            , isRequired = True
            , errors = errors Types.Start model
            }

        cancelButton =
            ( "Cancel", Types.CancelEdit )
    in
        div
            []
            [ form
                [ class formClass
                , onSubmit Types.SubmitForm
                ]
              <|
                formErrors (errors Types.Summary model)
                    :: inputField titleField
                    ++ inputField startField
                    ++ List.singleton (editHouseguests model)
                    ++ List.singleton (formButtons "Save" [ cancelButton ])
            ]


viewHouseguests : List Player -> Html Msg
viewHouseguests players =
    div
        []
        [ text "Houseguests"
        , ul
            []
            (List.map viewHouseguest players)
        ]


viewHouseguest : Player -> Html Msg
viewHouseguest player =
    let
        name =
            getName player

        url =
            "/players/" ++ toString player.id
    in
        li
            []
            [ a
                [ href url ]
                [ text name ]
            ]


editHouseguests : Model -> Html Msg
editHouseguests model =
    div
        []
        [ text "Houseguests"
        , div
            []
            [ select
                [ onInput (updateSelectedPlayer model) ]
              <|
                (defaultPlayer model)
                    :: (List.map (playerOption model) model.allPlayers)
            , button
                [ onClick Types.AddHouseguest
                , type_ "button"
                ]
                [ text "Add" ]
            ]
        , div
            []
          <|
            List.map
                editHouseguest
            <|
                (getSeason >> .houseguests)
                    model
        ]


editHouseguest : Player -> Html Msg
editHouseguest houseguest =
    div
        []
        [ text (getName houseguest)
        , iconWithOptions
            timesCircle
            FA.Solid
            []
            [ class "clickable"
            , onClick (Types.RemoveHouseguest houseguest)
            ]
        ]


defaultPlayer : Model -> Html Msg
defaultPlayer model =
    option
        [ value "N/A"
        , selected (model.selectedPlayer == Nothing)
        ]
        [ text "Select a player" ]


playerOption : Model -> Player -> Html Msg
playerOption model player =
    let
        isSelected =
            case model.selectedPlayer of
                Nothing ->
                    player.id == -1

                Just selectedPlayer ->
                    player.id == selectedPlayer.id
    in
        option
            [ value (toString player.id)
            , selected isSelected
            ]
            [ text (getName player) ]


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


isEditing : Model -> Bool
isEditing model =
    Editable.isEditable model.season


getName : Player -> String
getName player =
    playerName player.firstName player.lastName player.nickname


getPlayer : Model -> Int -> Maybe Player
getPlayer model id =
    find
        (\player -> player.id == id)
        model.allPlayers


updateSelectedPlayer : Model -> String -> Msg
updateSelectedPlayer model val =
    String.toInt val
        |> Result.toMaybe
        |> Maybe.andThen (getPlayer model)
        |> Types.SetSelectedPlayer
