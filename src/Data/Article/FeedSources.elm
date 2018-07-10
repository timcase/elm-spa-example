module Data.Article.FeedSources exposing (FeedSources, Source(..), fromLists, selected)

import Data.Article as Article
import Data.Article.Feed as Feed
import Data.Article.Tag as Tag exposing (Tag)
import Data.User.Username as Username exposing (Username)



-- TYPES


type FeedSources
    = FeedSources
        { before : List Source
        , selected : Source
        , after : List Source
        }


type Source
    = YourFeed
    | GlobalFeed
    | TagFeed Tag
    | FavoritedFeed Username
    | AuthorFeed Username



-- BUILDING


fromLists : Source -> List Source -> FeedSources
fromLists selectedSource afterSources =
    FeedSources
        { before = []
        , selected = selectedSource
        , after = afterSources
        }



-- SELECTING


select : Source -> FeedSources -> FeedSources
select selectedSource (FeedSources sources) =
    let
        ( newBefore, newAfter ) =
            (sources.before ++ (sources.selected :: sources.after))
                -- By design, tags can only be included if they're selected.
                |> List.filter isNotTag
                |> splitOn (\source -> source == selectedSource)
    in
    FeedSources
        { before = List.reverse newBefore
        , selected = selectedSource
        , after = List.reverse newAfter
        }


splitOn : (Source -> Bool) -> List Source -> ( List Source, List Source )
splitOn isSelected sources =
    let
        ( _, newBefore, newAfter ) =
            List.foldl (splitOnHelp isSelected) ( False, [], [] ) sources
    in
    ( newBefore, newAfter )


splitOnHelp : (Source -> Bool) -> Source -> ( Bool, List Source, List Source ) -> ( Bool, List Source, List Source )
splitOnHelp isSelected source ( foundSelected, beforeSelected, afterSelected ) =
    if isSelected source then
        ( True, beforeSelected, afterSelected )

    else if foundSelected then
        ( foundSelected, beforeSelected, source :: afterSelected )

    else
        ( foundSelected, source :: beforeSelected, afterSelected )


isNotTag : Source -> Bool
isNotTag currentSource =
    case currentSource of
        TagFeed _ ->
            False

        _ ->
            True



-- ACCESSING


selected : FeedSources -> Source
selected (FeedSources record) =
    record.selected


toList : FeedSources -> List Source
toList (FeedSources sources) =
    List.append sources.before (sources.selected :: sources.after)