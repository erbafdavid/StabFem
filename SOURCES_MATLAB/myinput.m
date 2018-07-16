function answer = myinput(question, default)
answer = input([question, ' [default : ', num2str(default), ' ] : ']);
if isempty(answer)
    answer = default;
end