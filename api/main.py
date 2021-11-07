from typing import List
import time

class Monomial:
    def __init__(self, exponent:int, coefficient) -> None:
        self.exponent:int = exponent
        self.coefficient = Fraction(coefficient, 1) if type(coefficient) == int else coefficient

    def __add__(self, otherMono):
        assert self.exponent == otherMono.exponent
        return Monomial(self.exponent, self.coefficient + otherMono.coefficient)

    def __sub__(self, otherMono):
        assert self.exponent == otherMono.exponent
        return Monomial(self.exponent, self.coefficient - otherMono.coefficient)

    def __mul__(self, otherMono):
        return Monomial(self.exponent + otherMono.exponent, self.coefficient*otherMono.coefficient)

    def __truediv__(self, otherMono):
        return Monomial(self.exponent - otherMono.exponent, self.coefficient/otherMono.coefficient)

def gcd(a:int, b:int) -> int:
    if type(b) == Fraction: 
        assert b.mother == 1
        b = b.child
    while b != 0:
        r = a % b
        a = b
        b = r
    return a

def lcm(a:int, b:int) -> int:
    return (a*b)/gcd(a,b)

class Fraction:
    def __init__(self, child:int, mother:int) -> None:
        assert mother != 0
        self.mother:int = mother
        self.child:int = child
    

    def __add__(self, otherFrac):
        if type(otherFrac) == int: return Fraction(self.child + otherFrac*self.mother, self.mother)
        tmpMother:int = self.mother * otherFrac.mother
        tmpChild:int = self.child*otherFrac.mother + otherFrac.child*self.mother
        tmpGcd:int = gcd(tmpMother, tmpChild)
        return Fraction(tmpChild//tmpGcd, tmpMother//tmpGcd)

    def __radd__(self, otherInt):
        return Fraction(otherInt*self.mother + self.child, self.mother)

    def __sub__(self, otherFrac):
        tmpMother:int = self.mother * otherFrac.mother
        tmpChild:int = self.child*otherFrac.mother - otherFrac.child*self.mother
        tmpGcd:int = gcd(tmpMother, tmpChild)
        return Fraction(tmpChild//tmpGcd, tmpMother//tmpGcd)

    def __mul__(self, otherFrac):
        if type(otherFrac) == int: return Fraction(self.child * otherFrac, self.mother)
        tmpMother:int = self.mother * otherFrac.mother
        tmpChild:int = self.child * otherFrac.child
        tmpGcd:int = gcd(tmpMother, tmpChild)
        return Fraction(tmpChild//tmpGcd, tmpMother//tmpGcd)

    def __truediv__(self, otherFrac):
        if type(otherFrac) == int: return Fraction(self.child, self.mother * otherFrac)
        tmpMother:int = self.mother * otherFrac.child
        tmpChild:int = self.child * otherFrac.mother
        tmpGcd:int = gcd(tmpMother, tmpChild)
        return Fraction(tmpChild//tmpGcd, tmpMother//tmpGcd)



class Polynomial:
    def __init__(self, elements:List = []) -> None:
        self.things = elements
        self.things.sort(key = lambda x:x.exponent)

    def append(self, thing) -> None:
        for i in self.things:
            if thing.exponent == i.exponent:
                i.coefficient += thing.coefficient
                return
        self.things.append(thing)
        self.things.sort(key = lambda x:x.exponent)

    def __add__(self, otherPoly):
        tmp = Polynomial([])
        for i in self.things:
            tmp.append(i)
        for i in otherPoly.things:
            tmp.append(i)
        visualize(tmp)
        return tmp
    
    def __sub__(self, otherPoly):
        return self + (otherPoly*Polynomial([Monomial(0, Fraction(-1, 1))]))

    def __mul__(self, otherPoly):
        tmp = []
        for i in range(len(self.things)):
            tmp.append([self.things[i]*x for x in otherPoly.things])
        ans = Polynomial()
        for i in tmp:
            ans += Polynomial(i)
        return ans
    def __truediv__(self, otherInt):
        return Polynomial([x/otherInt for x in self.things])
    
    def optimize(self):
        toDel = []
        for i in range(len(self.things)):
            if type(self.things[i].coefficient) == Fraction:
                if self.things[i].coefficient.child == 0: toDel.append(i)
            else:
                if self.things[i].coefficient == 0: toDel.append(i)
        for i in range(len(toDel)):
            del self.things[toDel[i] - i]
        tmp = Polynomial([])
        for i in self.things:
            tmp.append(i)
        self.things = tmp.things
def factorial(i:int) -> int:
    tmp = 1
    for i in range(1, i+1):
        tmp *= i
    return tmp

def nCr(n:int, r:int) -> int:
    return factorial(n)//(factorial(n-r)*factorial(r))

def expandNPlus1(k:int):
    tmp = []
    for i in range(k+1):
        tmp.append(Monomial(i, nCr(k, i)))
    return Polynomial(tmp)

def makeEquation(k:int):
    global sumCache
    assert k >= 0
    if k < len(sumCache): return sumCache[k]
    tmp = expandNPlus1(k+1)
    tmp.append(Monomial(0, Fraction(-1,1)))
    for i in range(0, k):
        a = makeEquation(i)
        tmp += a*Polynomial([Monomial(0, Fraction(-nCr(k+1, k + 1 - i), 1))])
    for i in tmp.things:
        i.coefficient *= Fraction(1, k+1)
    tmp.optimize()
    sumCache.append(tmp)
    return tmp

def visualFrac(frac, ex):
    sgn = '-'
    if frac.child * frac.mother > 0: sgn = ''
    co = f'\\frac{{{abs(frac.child)}}}{{{abs(frac.mother)}}}'
    if frac.child % frac.mother == 0:
        co = abs(frac.child//frac.mother)
        if co == 1 and ex != 0: co = ''
    return f'{co}'

def visualize(poly):
    buffer = []
    for i in range(len(poly.things)):
        tmp = poly.things[-i - 1]
        ex = tmp.exponent
        co = visualFrac(tmp.coefficient, ex)
        if i == 0:
            if ex == 0: buffer.append(f'{co}')
            elif ex == 1: buffer.append(f'{co}n')
            else: buffer.append(f'{co}n^{{{tmp.exponent}}}')
        else:
            sgn = '-'
            if tmp.coefficient.mother * tmp.coefficient.child > 0: sgn = '+'
            if ex == 0: buffer.append(f' {sgn} {co}')
            elif ex == 1: buffer.append(f' {sgn} {co}n')
            else: buffer.append(f' {sgn} {co}n^{{{tmp.exponent}}}')
    return buffer

def getVal(poly, n):
    s = 0
    for i in poly.things:
        s += i.coefficient * pow(n, i.exponent)
    return s.child//s.mother

def getValNaive(k, n):
    s = 0
    for i in range(1, n+1):
        s += pow(i, k)
    return s

sumCache = [Polynomial([Monomial(1, Fraction(1, 1))]), Polynomial([Monomial(2, Fraction(1,2)), Monomial(1, Fraction(1,2))])]

def Test(k = range(1, 100), n = 10):
    makeEquation(100)
    for i in k:
        a = getVal(sumCache[i], n)
        b = getValNaive(i, n)
        if a != b:
            print(i, a, b)

def makeTexfile(fname):
    with open(f'{fname}.tex', 'w') as f:
        n = 100
        f.write('\\documentclass{article}\n')
        f.write('\\usepackage{kotex}\n')
        f.write('\\usepackage{amsmath}\n')
        f.write('\\allowdisplaybreaks[4]\n')
        f.write('\\begin{document}\n')
        a = makeEquation(n)
        a.optimize()
        buffer = visualize(a)
        tmp = ''
        for i in buffer:
            tmp += i
        tex = f'\\sum\\limits_{{k = 1}}^{{n}}{{k^{{{n}}}}}={tmp}\n'
        n += 1
        f.write("    \\begin{multiline*}\n")
        f.write("        " + tex + "\n")
        f.write("    \\end{multiline*}\n")
        f.write('\\end{document}')
if __name__ == '__main__':
    makeTexfile('asdfasdfsad')
