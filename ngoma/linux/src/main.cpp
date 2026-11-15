#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

#include "viewmodels.hpp"

int main(int argc, char *argv[])
{
    initTModeler();

    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Basic");

    // ViewModel d'exemple, utilisable en QML : import models 1.0
    qmlRegisterType<NoteViewModel>("models", 1, 0, "NoteViewModel");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("ai.tambo.foundation.ngoma", "Main");

    return app.exec();
}
