CREATE VIEW vHistoricalPricesReporting 
AS
    SELECT 
        hist.FactID,
        hist.[Date],
        hist.[Open],
        hist.High,
        hist.Low,
        hist.[Close],
        hist.AdjClose,
        hist.Volume,
        sec.Company,
        sec.Symbol,
        sec.Industry,
        sec.IndexWeighting,
        exc.Symbol AS Exchange
    FROM
        FactPrices_Daily AS hist 
        INNER JOIN dimSecurity AS sec
        ON hist.SecurityID = sec.ID 
        INNER JOIN dimExchange AS exc
        ON sec.ExchangeID = exc.ID
GO