cd ../
werl +P 1024000 -smp auto -pa _build/default/lib/*/ebin -name game1@127.0.0.1 -setcookie game1 -boot start_sasl -config config/game1.config -s main start