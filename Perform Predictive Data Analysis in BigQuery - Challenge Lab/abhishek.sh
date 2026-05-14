#!/bin/bash

# Color variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# Banner function
function show_banner() {
    echo
    echo "${CYAN_TEXT}${BOLD_TEXT}╔══════════════════════════════════════════════════╗${RESET_FORMAT}"
    echo "${CYAN_TEXT}${BOLD_TEXT}║     WELCOME TO DR ABHISHEK CLOUD TUTORIALS LET'S      ║${RESET_FORMAT}"
    echo "${CYAN_TEXT}${BOLD_TEXT}║              LEARN AND EXPLORE CLOUD                   ║${RESET_FORMAT}"
    echo "${CYAN_TEXT}${BOLD_TEXT}╚══════════════════════════════════════════════════╝${RESET_FORMAT}"
    echo
    echo "${GREEN_TEXT}For more cloud tutorials, subscribe to:${RESET_FORMAT}"
    echo "${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
    echo "${YELLOW_TEXT}──────────────────────────────────────────────${RESET_FORMAT}"
}

show_banner

# User input section
echo "${MAGENTA_TEXT}${BOLD_TEXT}Please enter the following configuration details:${RESET_FORMAT}"
echo

read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter value for EVENT: ${RESET_FORMAT}" EVENT
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter value for TABLE: ${RESET_FORMAT}" TABLE
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter value for VALUE_X1: ${RESET_FORMAT}" VALUE_X1
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter value for VALUE_Y1: ${RESET_FORMAT}" VALUE_Y1
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter value for VALUE_X2: ${RESET_FORMAT}" VALUE_X2
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter value for VALUE_Y2: ${RESET_FORMAT}" VALUE_Y2
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter value for FUNC_1: ${RESET_FORMAT}" FUNC_1
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter value for FUNC_2: ${RESET_FORMAT}" FUNC_2
echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter value for MODEL: ${RESET_FORMAT}" MODEL

# Export variables
export EVENT TABLE VALUE_X1 VALUE_Y1 VALUE_X2 VALUE_Y2 FUNC_1 FUNC_2 MODEL

# Show configuration summary
echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║          CONFIGURATION SUMMARY             ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╠════════════════════════════════════════════╣${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║ ${CYAN_TEXT}EVENT:${RESET_FORMAT} $EVENT"
echo "${GREEN_TEXT}${BOLD_TEXT}║ ${CYAN_TEXT}TABLE:${RESET_FORMAT} $TABLE"
echo "${GREEN_TEXT}${BOLD_TEXT}║ ${CYAN_TEXT}Coordinates:${RESET_FORMAT} ($VALUE_X1,$VALUE_Y1) ($VALUE_X2,$VALUE_Y2)"
echo "${GREEN_TEXT}${BOLD_TEXT}║ ${CYAN_TEXT}Functions:${RESET_FORMAT} $FUNC_1, $FUNC_2"
echo "${GREEN_TEXT}${BOLD_TEXT}║ ${CYAN_TEXT}Model:${RESET_FORMAT} $MODEL"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════╝${RESET_FORMAT}"
echo

# Data loading section
echo "${MAGENTA_TEXT}${BOLD_TEXT}⚽ Loading soccer data into BigQuery tables...${RESET_FORMAT}"
bq load --source_format=NEWLINE_DELIMITED_JSON --autodetect $DEVSHELL_PROJECT_ID:soccer.$EVENT gs://spls/bq-soccer-analytics/events.json && \
echo "${GREEN_TEXT}✓ Events data loaded${RESET_FORMAT}" || echo "${RED_TEXT}✗ Failed to load events${RESET_FORMAT}"

bq load --source_format=CSV --autodetect $DEVSHELL_PROJECT_ID:soccer.$TABLE gs://spls/bq-soccer-analytics/tags2name.csv && \
echo "${GREEN_TEXT}✓ Tags data loaded${RESET_FORMAT}" || echo "${RED_TEXT}✗ Failed to load tags${RESET_FORMAT}"

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $DEVSHELL_PROJECT_ID:soccer.competitions gs://spls/bq-soccer-analytics/competitions.json && \
echo "${GREEN_TEXT}✓ Competitions data loaded${RESET_FORMAT}" || echo "${RED_TEXT}✗ Failed to load competitions${RESET_FORMAT}"

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $DEVSHELL_PROJECT_ID:soccer.matches gs://spls/bq-soccer-analytics/matches.json && \
echo "${GREEN_TEXT}✓ Matches data loaded${RESET_FORMAT}" || echo "${RED_TEXT}✗ Failed to load matches${RESET_FORMAT}"

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $DEVSHELL_PROJECT_ID:soccer.teams gs://spls/bq-soccer-analytics/teams.json && \
echo "${GREEN_TEXT}✓ Teams data loaded${RESET_FORMAT}" || echo "${RED_TEXT}✗ Failed to load teams${RESET_FORMAT}"

bq load --autodetect --source_format=NEWLINE_DELIMITED_JSON $DEVSHELL_PROJECT_ID:soccer.players gs://spls/bq-soccer-analytics/players.json && \
echo "${GREEN_TEXT}✓ Players data loaded${RESET_FORMAT}" || echo "${RED_TEXT}✗ Failed to load players${RESET_FORMAT}"

echo
echo "${GREEN_TEXT}${BOLD_TEXT}All data loaded successfully!${RESET_FORMAT}"
echo

# Query execution section
echo "${BLUE_TEXT}${BOLD_TEXT}🔍 Analyzing penalty kick success rates...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
playerId,
(Players.firstName || ' ' || Players.lastName) AS playerName,
COUNT(id) AS numPKAtt,
SUM(IF(101 IN UNNEST(tags.id), 1, 0)) AS numPKGoals,
SAFE_DIVIDE(
SUM(IF(101 IN UNNEST(tags.id), 1, 0)),
COUNT(id)
) AS PKSuccessRate
FROM
\`soccer.$EVENT\` Events
LEFT JOIN
\`soccer.players\` Players ON
Events.playerId = Players.wyId
WHERE
eventName = 'Free Kick' AND
subEventName = 'Penalty'
GROUP BY
playerId, playerName
HAVING
numPkAtt >= 5
ORDER BY
PKSuccessRate DESC, numPKAtt DESC
"

echo
echo "${BLUE_TEXT}${BOLD_TEXT}📊 Analyzing shot distances and goal percentages...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
WITH
Shots AS
(
SELECT
*,
(101 IN UNNEST(tags.id)) AS isGoal,
SQRT(
POW(
    (100 - positions[ORDINAL(1)].x) * $VALUE_X1/$VALUE_Y1,
    2) +
POW(
    (60 - positions[ORDINAL(1)].y) * $VALUE_X2/$VALUE_Y2,
    2)
 ) AS shotDistance
FROM
\`soccer.$EVENT\`
WHERE
eventName = 'Shot' OR
(eventName = 'Free Kick' AND subEventName IN ('Free kick shot', 'Penalty'))
)
SELECT
ROUND(shotDistance, 0) AS ShotDistRound0,
COUNT(*) AS numShots,
SUM(IF(isGoal, 1, 0)) AS numGoals,
AVG(IF(isGoal, 1, 0)) AS goalPct
FROM
Shots
WHERE
shotDistance <= 50
GROUP BY
ShotDistRound0
ORDER BY
ShotDistRound0
"

# Model creation section
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}🤖 Creating machine learning model for shot predictions...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
CREATE MODEL \`$MODEL\`
OPTIONS(
model_type = 'LOGISTIC_REG',
input_label_cols = ['isGoal']
) AS
SELECT
Events.subEventName AS shotType,
(101 IN UNNEST(Events.tags.id)) AS isGoal,
\`$FUNC_1\`(Events.positions[ORDINAL(1)].x,
Events.positions[ORDINAL(1)].y) AS shotDistance,
\`$FUNC_2\`(Events.positions[ORDINAL(1)].x,
Events.positions[ORDINAL(1)].y) AS shotAngle
FROM
\`soccer.$EVENT\` Events
LEFT JOIN
\`soccer.matches\` Matches ON
Events.matchId = Matches.wyId
LEFT JOIN
\`soccer.competitions\` Competitions ON
Matches.competitionId = Competitions.wyId
WHERE
Competitions.name != 'World Cup' AND
(
eventName = 'Shot' OR
(eventName = 'Free Kick' AND subEventName IN ('Free kick shot', 'Penalty'))
) AND
\`$FUNC_2\`(Events.positions[ORDINAL(1)].x,
Events.positions[ORDINAL(1)].y) IS NOT NULL
;
" && echo "${GREEN_TEXT}✓ Model created successfully${RESET_FORMAT}" || echo "${RED_TEXT}✗ Model creation failed${RESET_FORMAT}"

# Prediction section
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}🔮 Running predictions using the created model...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT
predicted_isGoal_probs[ORDINAL(1)].prob AS predictedGoalProb,
* EXCEPT (predicted_isGoal, predicted_isGoal_probs),
FROM
ML.PREDICT(
MODEL \`$MODEL\`, 
(
 SELECT
     Events.playerId,
     (Players.firstName || ' ' || Players.lastName) AS playerName,
     Teams.name AS teamName,
     CAST(Matches.dateutc AS DATE) AS matchDate,
     Matches.label AS match,
     CAST((CASE
         WHEN Events.matchPeriod = '1H' THEN 0
         WHEN Events.matchPeriod = '2H' THEN 45
         WHEN Events.matchPeriod = 'E1' THEN 90
         WHEN Events.matchPeriod = 'E2' THEN 105
         ELSE 120
         END) +
         CEILING(Events.eventSec / 60) AS INT64)
         AS matchMinute,
     Events.subEventName AS shotType,
     (101 IN UNNEST(Events.tags.id)) AS isGoal,
     \`soccer.$FUNC_1\`(Events.positions[ORDINAL(1)].x,
             Events.positions[ORDINAL(1)].y) AS shotDistance,
     \`soccer.$FUNC_2\`(Events.positions[ORDINAL(1)].x,
             Events.positions[ORDINAL(1)].y) AS shotAngle
 FROM
     \`soccer.$EVENT\` Events
 LEFT JOIN
     \`soccer.matches\` Matches ON
             Events.matchId = Matches.wyId
 LEFT JOIN
     \`soccer.competitions\` Competitions ON
             Matches.competitionId = Competitions.wyId
 LEFT JOIN
     \`soccer.players\` Players ON
             Events.playerId = Players.wyId
 LEFT JOIN
     \`soccer.teams\` Teams ON
             Events.teamId = Teams.wyId
 WHERE
     Competitions.name = 'World Cup' AND
     (
         eventName = 'Shot' OR
         (eventName = 'Free Kick' AND subEventName IN ('Free kick shot'))
     ) AND
     (101 IN UNNEST(Events.tags.id))
)
)
ORDER BY
predictedgoalProb
"

# Completion message
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}║          LIKE THE VIDEO & SUBSCRIBE THE CHANNEL !                ║${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Next steps:${RESET_FORMAT}"
echo "${WHITE_TEXT}- Review the results in BigQuery Console:"
echo "${BLUE_TEXT}  https://console.cloud.google.com/bigquery${RESET_FORMAT}"
echo "${WHITE_TEXT}- For more tutorials, subscribe to Dr. Abhishek's channel:"
echo "${BLUE_TEXT}  https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}Happy analyzing! ⚽📊${RESET_FORMAT}"
