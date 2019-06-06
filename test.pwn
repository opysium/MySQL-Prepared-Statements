// generated by "sampctl package generate"

#include <a_mysql>

#include "MySQL-Stataments/Statament.inc"

new MySQL:sql;

new
    Statement:stmt_readone,
    Statement:stmt_readloop;



main() {

    sql = mysql_connect("localhost", "root", "", "cnr");

    mysql_log(ALL);

    new Statement: stmt_insert = MySQL_PrepareStatement(sql, "INSERT INTO accounts(username, password, salt, money, kills, deaths) VALUES (?,?,?,?,?,?) " );

    // Arrow values in questions (first 0, second is 1, etc ...)
    MySQL_Bind(stmt_insert, 0 , "patrickgtr");
    MySQL_Bind(stmt_insert, 1 , "patrickgtrpassword");
    MySQL_Bind(stmt_insert, 2 , "pgtrhash");
    MySQL_BindInt(stmt_insert, 3, 100);
    MySQL_BindInt(stmt_insert, 4, 200);
    MySQL_BindInt(stmt_insert, 5, 300);

    MySQL_ExecuteParallel(stmt_insert);
    MySQL_StatementClose(stmt_insert);

    stmt_readone = MySQL_PrepareStatement(sql, "SELECT username, password, salt, money, kills, deaths FROM accounts where username = ?");
    stmt_readloop = MySQL_PrepareStatement(sql, "SELECT * FROM spawns");

    // Run Threaded on statement
    MySQL_ExecuteThreaded(stmt_readloop, "OnSpawnsLoad");

    SetTimerEx("Emulate_OnPlayerConnect", 2000, false, "i", 0);
}

forward OnSpawnsLoad();
public OnSpawnsLoad() {
    new
        spawnID,
        Float:spawnX,
        Float:spawnY,
        Float:spawnZ,
        Float:spawnA;

    MySQL_BindResultInt(stmt_readloop, 0, spawnID);
    MySQL_BindResultFloat(stmt_readloop, 1, spawnX);
    MySQL_BindResultFloat(stmt_readloop, 2, spawnY);
    MySQL_BindResultFloat(stmt_readloop, 3, spawnZ);
    MySQL_BindResultFloat(stmt_readloop, 4, spawnA);

    while(stmt_fetch_row(stmt_readloop)) {
        printf("%i, %.3f, %.3f, %.3f", spawnID, spawnX, spawnY, spawnZ, spawnA);
    }
    MySQL_StatementClose(stmt_readloop);
}

forward Emulate_OnPlayerConnect(playerid);
public Emulate_OnPlayerConnect(playerid) {
    printf("OPC, playerid: %i", playerid);
    MySQL_Bind(stmt_readone, 0, "patrickgtr");
    MySQL_ExecuteThreaded(stmt_readone, "OnPlayerLoad", "isf", playerid, "Hello World;", 192.168);
    return 1;
}

forward OnPlayerLoad(playerid,const fmat[], Float:pos);
public OnPlayerLoad(playerid, const fmat[], Float:pos)
{
    printf("OPL, playerid: %i", playerid);
    printf("OPL, fmat: %s", fmat);
    printf("OPL, pos: %.4f", pos);

    new
        playerUsername[MAX_PLAYER_NAME],
        playerPassword[65],
        playerSalt[11],
        playerMoney,
        playerKills,
        playerDeaths;

    // retrieve
    MySQL_BindResult(stmt_readone, 0, playerUsername, sizeof(playerUsername));
    MySQL_BindResult(stmt_readone, 1, playerPassword, sizeof(playerPassword));
    MySQL_BindResult(stmt_readone, 2, playerSalt, sizeof(playerSalt));
    MySQL_BindResultInt(stmt_readone, 3, playerMoney);
    MySQL_BindResultInt(stmt_readone, 4, playerKills);
    MySQL_BindResultInt(stmt_readone, 5, playerDeaths);

    if(stmt_fetch_row(stmt_readone)) {
        printf("username %s", playerUsername);
        printf("password %s", playerPassword);
        printf("salt %s", playerSalt);
        printf("money %i", playerMoney);
        printf("kills %i", playerKills);
        printf("deaths %i", playerDeaths);
    }
    MySQL_StatementClose(stmt_readone);
}