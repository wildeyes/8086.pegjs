var gulp = require("gulp")
    , mocha = require("gulp-mocha")
    
    , testFile

gulp.task("default", function() {
    gulp.watch(["test/test.js","src/8086.pegjs"], ["test"]);
    gulp.start("test")
});
gulp.task("test",function () {
    return gulp.src('./test/test.js')
        .pipe(mocha({reporter: 'spec'})); 
});
