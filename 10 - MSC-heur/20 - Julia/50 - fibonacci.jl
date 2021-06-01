# fibonacci.jl

function fib_recursive(n::Int)
    if n == 1 || n == 0
        return n
    end
    return fib_recursive(n - 1) + fib_recursive(n - 2)
end

function fib_iterative(n::Int)
    x = 0
    y = 1
    z = 1
    for _ in 1:n
        x = y
        y = z
        z = x + y
    end
    return x
end

function fib_matrix(n::Int)
    if n == 0
        return 0
    end
    F = [1 1; 1 0]^(n - 1)
    return F[1, 1]
end

function fib_magic(n::Int)
    phi = (1 + sqrt(5.0)) / 2.0
    return round(Integer, (phi^n) / sqrt(5.0))
end

function fib(n::Int)
    println()
    val = fib_recursive(n)
    println("fib_recursive = ", '\t', val)

    val = fib_iterative(n)
    println("fib_iterative = ", '\t', val)

    val = fib_matrix(n)
    println("fib_matrix    = ", '\t', val)

    val = fib_magic(n)
    println("fib_magic     = ", '\t', val)

    return
end

fib(40)
