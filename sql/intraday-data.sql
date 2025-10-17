CREATE VIEW vIntraDayPricesReporting
AS
    SELECT
        attr.FactID,
        attr.[DateTime],
        attr.LastBid,
        attr.High,
        attr.Low,
        attr.[Open],
        attr.Volume,
        attr.Beta,
        sec.Company,
        sec.Symbol,
        exc.Symbol AS Exchange
    FROM
        FactAttributes_Intraday attr
        JOIN dimSecurity AS sec
        ON attr.SecurityID = sec.ID
        JOIN dimExchange AS exc
        ON sec.ExchangeID = exc.ID
GO        