module Account.Profile.State exposing (init, subscriptions, update)

import Account.Profile.Rest as Rest exposing (saveProfile)
import Account.Profile.Types as Types exposing (Model, Msg)
import Editable
import Header.State
import Common.Commands exposing (send)
import Common.Rest exposing (fetch, userRequest)


initialModel : Model
initialModel =
    let
        user =
            { firstName = ""
            , lastName = ""
            , email = ""
            , bio = ""
            , avatarUrl = ""
            , isAdmin = False
            }
    in
        { user = Editable.ReadOnly user
        , header = Header.State.initialModel
        , pageState = Types.Loading
        }


init : ( Model, Cmd Msg )
init =
    ( initialModel, send Types.FetchUser )


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

        Types.FetchUser ->
            { model | pageState = Types.Loading }
                ! [ fetch userRequest Types.SetUser ]

        Types.SetUser (Err _) ->
            initialModel ! []

        Types.SetUser (Ok newUser) ->
            let
                header =
                    model.header

                headerModel =
                    { header | user = Just newUser }
            in
                ( { model
                    | user = Editable.ReadOnly newUser
                    , header = headerModel
                    , pageState = Types.Loaded
                  }
                , Cmd.none
                )

        Types.EditProfile ->
            { model | user = Editable.edit model.user } ! []

        Types.CancelEdit ->
            { model | user = Editable.cancel model.user } ! []

        Types.SaveEdit ->
            { model
                | user = Editable.save model.user
                , pageState = Types.Loading
            }
                ! [ saveProfile <| .bio (Editable.value model.user) ]

        Types.ViewProfile (Ok _) ->
            { model | pageState = Types.Loaded } ! []

        Types.ViewProfile (Err _) ->
            { model | pageState = Types.Loaded } ! []

        Types.UpdateBio newBio ->
            let
                updatedUser =
                    case model.user of
                        Editable.Editable saved modified ->
                            Editable.Editable
                                saved
                                { modified | bio = newBio }

                        Editable.ReadOnly _ ->
                            model.user
            in
                { model | user = updatedUser } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
