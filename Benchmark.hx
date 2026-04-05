class Benchmark {
    static function main() {
        var iterations = 100000000;
        var num1:Float = 10.5;
        var num2:Float = 20.7;

        var start = haxe.Timer.stamp();
        for (i in 0...iterations) {
            var dx:Float = num1 - num2;
            var res = Std.int(Math.sqrt(dx * dx));
        }
        var end = haxe.Timer.stamp();
        trace("Math.sqrt(dx * dx) took: " + (end - start) + "s");

        start = haxe.Timer.stamp();
        for (i in 0...iterations) {
            var dx:Float = num1 - num2;
            var res = Std.int(Math.abs(dx));
        }
        end = haxe.Timer.stamp();
        trace("Math.abs(dx) took: " + (end - start) + "s");
    }
}
