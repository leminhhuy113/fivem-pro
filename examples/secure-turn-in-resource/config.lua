Config = {}

-- auto | qbcore | esx | qbox. Set explicitly on production servers.
Config.Framework = 'auto'

Config.TurnIn = {
    coords = vector3(0.0, 0.0, 0.0), -- replace before enabling the resource
    radius = 3.0,
    minimumDurationSeconds = 15,
    reward = 100,
    currency = 'cash',
}
