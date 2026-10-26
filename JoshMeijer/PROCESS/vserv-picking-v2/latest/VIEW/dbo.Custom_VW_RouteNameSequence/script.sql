CREATE VIEW [dbo].[Custom_VW_RouteNameSequence]
AS
SELECT
RouteName, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) SequenceNumber
FROM
(
SELECT 'Cash & Collections' AS RouteName
UNION ALL
SELECT 'ABS route' AS RouteName
UNION ALL
SELECT 'Garden Route' AS RouteName
UNION ALL
SELECT 'Courier inland' AS RouteName
UNION ALL
SELECT 'Courier Sunshine coast' AS RouteName
UNION ALL
SELECT 'Courier Garden route' AS RouteName
UNION ALL
SELECT 'Courier East London' AS RouteName
UNION ALL
SELECT 'Courier Intercompany (CPT)' AS RouteName
UNION ALL
SELECT 'None' AS RouteName
UNION ALL
SELECT 'Jeffreysbay' AS RouteName
UNION ALL
SELECT 'Courier Morning PE' AS RouteName
UNION ALL
SELECT 'Summerstrand' AS RouteName
UNION ALL
SELECT 'Walmer' AS RouteName
UNION ALL
SELECT 'East London Branch' AS RouteName
UNION ALL
SELECT 'Upper PE Route' AS RouteName
UNION ALL
SELECT 'Newton Park' AS RouteName
UNION ALL
SELECT 'Lynn Route' AS RouteName
) RouteSequences
WHERE CONVERT(TIME, GETDATE()) < '11:00:00'
UNION ALL
SELECT
RouteName, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) SequenceNumber
FROM
(
SELECT 'Cash & Collections' AS RouteName
UNION ALL
SELECT 'ABS route' AS RouteName
UNION ALL
SELECT 'Garden Route' AS RouteName
UNION ALL
SELECT 'Jeffreysbay' AS RouteName
UNION ALL
SELECT 'Courier Morning PE' AS RouteName
UNION ALL
SELECT 'Summerstrand' AS RouteName
UNION ALL
SELECT 'Walmer' AS RouteName
UNION ALL
SELECT 'East London Branch' AS RouteName
UNION ALL
SELECT 'Upper PE Route' AS RouteName
UNION ALL
SELECT 'Newton Park' AS RouteName
UNION ALL
SELECT 'Lynn Route' AS RouteName
UNION ALL
SELECT 'Courier inland' AS RouteName
UNION ALL
SELECT 'Courier Sunshine coast' AS RouteName
UNION ALL
SELECT 'Courier Garden route' AS RouteName
UNION ALL
SELECT 'Courier East London' AS RouteName
UNION ALL
SELECT 'Courier Intercompany (CPT)' AS RouteName
UNION ALL
SELECT 'None' AS RouteName
) RouteSequences
WHERE CONVERT(TIME, GETDATE()) >= '11:00:00'
